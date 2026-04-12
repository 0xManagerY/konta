import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  static OcrService get instance => _instance;

  OcrService._internal();

  late final TextRecognizer _textRecognizer = TextRecognizer();

  Future<OcrResult> processReceipt(String imagePath) async {
    Logger.info('processReceipt started for: $imagePath', tag: 'OCR');
    try {
      Logger.info('Compressing image', tag: 'OCR');
      final compressedPath = await _compressImage(imagePath);
      Logger.info('Image compressed to: $compressedPath', tag: 'OCR');

      Logger.info('Creating InputImage from file path', tag: 'OCR');
      final inputImage = InputImage.fromFilePath(compressedPath);
      Logger.info(
        'InputImage created, processing with TextRecognizer',
        tag: 'OCR',
      );
      final recognizedText = await _textRecognizer.processImage(inputImage);
      Logger.info('TextRecognizer completed', tag: 'OCR');

      final text = recognizedText.text;
      Logger.info('Recognized text length: ${text.length}', tag: 'OCR');

      final amounts = _extractAmounts(text);
      final date = _extractDate(text);
      final merchantName = _extractMerchantName(text);

      Logger.info(
        'Extracted - amounts: $amounts, date: $date, merchant: $merchantName',
        tag: 'OCR',
      );

      return OcrResult(
        success: true,
        rawText: text,
        extractedAmount: amounts.isNotEmpty ? amounts.first : null,
        allAmounts: amounts,
        extractedDate: date,
        merchantName: merchantName,
        compressedImagePath: compressedPath,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'processReceipt error',
        tag: 'OCR',
        error: e,
        stackTrace: stackTrace,
      );
      return OcrResult(success: false, error: e.toString());
    }
  }

  Future<String> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result == null) {
        Logger.warning('Compression failed, using original', tag: 'OCR');
        return imagePath;
      }

      return result.path;
    } catch (e) {
      Logger.warning('Compression error: $e, using original', tag: 'OCR');
      return imagePath;
    }
  }

  List<double> _extractAmounts(String text) {
    final amounts = <double>[];

    final patterns = [
      RegExp(
        r'Total[:\s]*(\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(
        r'TTC[:\s]*(\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(
        r'Montant[:\s]*(\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(r'(\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2})\s*MAD', caseSensitive: false),
      RegExp(r'(\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2})\s*DH', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          final normalized = amountStr.replaceAll(' ', '').replaceAll(',', '.');
          final amount = double.tryParse(normalized);
          if (amount != null && amount > 0) {
            amounts.add(amount);
          }
        }
      }
    }

    final allNumbers = RegExp(r'\d{1,3}(?:[\s.,]\d{3})*[.,]\d{2}');
    final numberMatches = allNumbers.allMatches(text);
    for (final match in numberMatches) {
      final numStr = match.group(0);
      if (numStr != null) {
        final normalized = numStr.replaceAll(' ', '').replaceAll(',', '.');
        final num = double.tryParse(normalized);
        if (num != null && num > 10 && !amounts.contains(num)) {
          amounts.add(num);
        }
      }
    }

    return amounts..sort((a, b) => b.compareTo(a));
  }

  DateTime? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{2})[/-](\d{2})[/-](\d{4})'),
      RegExp(r'(\d{4})[/-](\d{2})[/-](\d{2})'),
      RegExp(
        r'(\d{2})\s*(janvier|février|mars|avril|mai|juin|juillet|août|septembre|octobre|novembre|décembre)\s*(\d{4})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          if (pattern == patterns[0]) {
            final day = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          } else if (pattern == patterns[1]) {
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }

    return null;
  }

  String? _extractMerchantName(String text) {
    final lines = text.split('\n');
    for (final line in lines.take(5)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length > 3 && trimmed.length < 50) {
        if (!RegExp(r'^[\d\s.,\-:]+$').hasMatch(trimmed)) {
          return trimmed;
        }
      }
    }
    return null;
  }
}

class OcrResult {
  final bool success;
  final String? error;
  final String? rawText;
  final double? extractedAmount;
  final List<double> allAmounts;
  final DateTime? extractedDate;
  final String? merchantName;
  final String? compressedImagePath;

  OcrResult({
    required this.success,
    this.error,
    this.rawText,
    this.extractedAmount,
    this.allAmounts = const [],
    this.extractedDate,
    this.merchantName,
    this.compressedImagePath,
  });
}
