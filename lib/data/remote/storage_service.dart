import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _bucketName = 'receipts';
  static const int _maxFileSize = 5 * 1024 * 1024;

  static Future<String?> uploadReceipt({
    required String localPath,
    required String userId,
  }) async {
    if (!SupabaseService.isAuthenticated) {
      Logger.warning('User not authenticated', tag: 'STORAGE');
      return null;
    }

    final file = File(localPath);
    if (!await file.exists()) {
      Logger.error('File not found: $localPath', tag: 'STORAGE');
      return null;
    }

    var fileToUpload = file;
    final fileSize = await file.length();

    if (fileSize > _maxFileSize) {
      Logger.info('Compressing image: ${fileSize}b', tag: 'STORAGE');
      final compressed = await _compressImage(localPath);
      if (compressed == null) return null;
      fileToUpload = compressed;
    }

    return _uploadFile(fileToUpload, userId);
  }

  static Future<File?> _compressImage(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        Logger.success(
          'Compressed: ${await compressedFile.length()}b',
          tag: 'STORAGE',
        );
        return compressedFile;
      }
    } catch (e, st) {
      Logger.error(
        'Compression failed',
        tag: 'STORAGE',
        error: e,
        stackTrace: st,
      );
    }
    return null;
  }

  static Future<String?> _uploadFile(File file, String userId) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final storagePath = '$userId/$fileName';

    try {
      Logger.network('UPLOAD', 'receipts/$storagePath');

      await SupabaseService.client.storage
          .from(_bucketName)
          .upload(storagePath, file);

      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      Logger.success('Uploaded: $publicUrl', tag: 'STORAGE');
      return publicUrl;
    } catch (e, st) {
      Logger.error('Upload failed', tag: 'STORAGE', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<File?> downloadReceipt(String url) async {
    try {
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.last;
      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/receipts/$fileName';

      final localFile = File(localPath);
      if (await localFile.exists()) {
        Logger.info('Receipt cached: $localPath', tag: 'STORAGE');
        return localFile;
      }

      Logger.network('DOWNLOAD', url);

      final response = await SupabaseService.client.storage
          .from(_bucketName)
          .download(uri.pathSegments.skip(1).join('/'));

      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes(response);

      Logger.success('Downloaded: $localPath', tag: 'STORAGE');
      return localFile;
    } catch (e, st) {
      Logger.error('Download failed', tag: 'STORAGE', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<void> deleteReceipt(String url) async {
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      final storagePath = uri.pathSegments.skip(1).join('/');

      Logger.network('DELETE', 'receipts/$storagePath');

      await SupabaseService.client.storage.from(_bucketName).remove([
        storagePath,
      ]);

      Logger.success('Deleted: $storagePath', tag: 'STORAGE');
    } catch (e, st) {
      Logger.error('Delete failed', tag: 'STORAGE', error: e, stackTrace: st);
    }
  }

  static bool isRemoteUrl(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  static bool isLocalPath(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('/') || path.startsWith('file://');
  }
}
