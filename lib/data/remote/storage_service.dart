import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final _log = LogService();
  static const String _bucketName = 'receipts';
  static const int _maxFileSize = 5 * 1024 * 1024;

  static Future<String?> uploadReceipt({
    required String localPath,
    required String userId,
  }) async {
    if (!SupabaseService.isAuthenticated) {
      _log.warn('Service', 'User not authenticated');
      return null;
    }

    final file = File(localPath);
    if (!await file.exists()) {
      _log.error('Service', 'File not found: $localPath');
      return null;
    }

    var fileToUpload = file;
    final fileSize = await file.length();

    if (fileSize > _maxFileSize) {
      _log.info('Service', 'Compressing image: ${fileSize}b');
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
        _log.info('Service', 'Compressed: ${await compressedFile.length()}b');
        return compressedFile;
      }
    } catch (e, st) {
      _log.error('Service', 'Compression failed', error: e, stack: st);
    }
    return null;
  }

  static Future<String?> _uploadFile(File file, String userId) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final storagePath = '$userId/$fileName';

    try {
      _log.info('Service', 'UPLOAD receipts/$storagePath');

      await SupabaseService.client.storage
          .from(_bucketName)
          .upload(storagePath, file);

      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      _log.info('Service', 'Uploaded: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      _log.error('Service', 'Upload failed', error: e, stack: st);
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
        _log.info('Service', 'Receipt cached: $localPath');
        return localFile;
      }

      _log.info('Service', 'DOWNLOAD $url');

      final response = await SupabaseService.client.storage
          .from(_bucketName)
          .download(uri.pathSegments.skip(1).join('/'));

      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes(response);

      _log.info('Service', 'Downloaded: $localPath');
      return localFile;
    } catch (e, st) {
      _log.error('Service', 'Download failed', error: e, stack: st);
      return null;
    }
  }

  static Future<void> deleteReceipt(String url) async {
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      final storagePath = uri.pathSegments.skip(1).join('/');

      _log.info('Service', 'DELETE receipts/$storagePath');

      await SupabaseService.client.storage.from(_bucketName).remove([
        storagePath,
      ]);

      _log.info('Service', 'Deleted: $storagePath');
    } catch (e, st) {
      _log.error('Service', 'Delete failed', error: e, stack: st);
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
