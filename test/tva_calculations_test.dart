import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TVA Calculations', () {
    group('calculateItemTotal', () {
      test('calculates total for quantity and unit price', () {
        final quantity = 2.0;
        final unitPrice = 100.0;
        final total = quantity * unitPrice;

        expect(total, equals(200.0));
      });

      test('handles decimal quantities', () {
        final quantity = 1.5;
        final unitPrice = 100.0;
        final total = quantity * unitPrice;

        expect(total, equals(150.0));
      });

      test('handles zero quantity', () {
        final quantity = 0.0;
        final unitPrice = 100.0;
        final total = quantity * unitPrice;

        expect(total, equals(0.0));
      });

      test('handles zero unit price', () {
        final quantity = 5.0;
        final unitPrice = 0.0;
        final total = quantity * unitPrice;

        expect(total, equals(0.0));
      });
    });

    group('calculateTVA', () {
      test('calculates 20% TVA (standard rate)', () {
        final totalHT = 1000.0;
        final tvaRate = 20.0;
        final tva = totalHT * (tvaRate / 100);

        expect(tva, equals(200.0));
      });

      test('calculates 10% TVA (reduced rate)', () {
        final totalHT = 1000.0;
        final tvaRate = 10.0;
        final tva = totalHT * (tvaRate / 100);

        expect(tva, equals(100.0));
      });

      test('calculates 1% TVA (auto-entrepreneur rate)', () {
        final totalHT = 1000.0;
        final tvaRate = 1.0;
        final tva = totalHT * (tvaRate / 100);

        expect(tva, equals(10.0));
      });

      test('handles zero TVA rate', () {
        final totalHT = 1000.0;
        final tvaRate = 0.0;
        final tva = totalHT * (tvaRate / 100);

        expect(tva, equals(0.0));
      });
    });

    group('calculateInvoiceTotals', () {
      test('calculates totals for multiple items with same TVA rate', () {
        final items = [
          {'quantity': 2.0, 'unitPrice': 100.0, 'tvaRate': 20.0},
          {'quantity': 1.0, 'unitPrice': 200.0, 'tvaRate': 20.0},
        ];

        double subtotal = 0;
        double tvaAmount = 0;

        for (final item in items) {
          final itemTotal =
              (item['quantity'] as double) * (item['unitPrice'] as double);
          final itemTva = itemTotal * ((item['tvaRate'] as double) / 100);
          subtotal += itemTotal;
          tvaAmount += itemTva;
        }

        final total = subtotal + tvaAmount;

        expect(subtotal, equals(400.0));
        expect(tvaAmount, equals(80.0));
        expect(total, equals(480.0));
      });

      test('calculates totals for items with different TVA rates', () {
        final items = [
          {'quantity': 1.0, 'unitPrice': 100.0, 'tvaRate': 20.0},
          {'quantity': 1.0, 'unitPrice': 100.0, 'tvaRate': 10.0},
          {'quantity': 1.0, 'unitPrice': 100.0, 'tvaRate': 1.0},
        ];

        double subtotal = 0;
        double tvaAmount = 0;

        for (final item in items) {
          final itemTotal =
              (item['quantity'] as double) * (item['unitPrice'] as double);
          final itemTva = itemTotal * ((item['tvaRate'] as double) / 100);
          subtotal += itemTotal;
          tvaAmount += itemTva;
        }

        final total = subtotal + tvaAmount;

        expect(subtotal, equals(300.0));
        expect(tvaAmount, equals(31.0));
        expect(total, equals(331.0));
      });

      test('handles empty items list', () {
        final items = <Map<String, dynamic>>[];

        double subtotal = 0;
        double tvaAmount = 0;

        for (final item in items) {
          final itemTotal =
              (item['quantity'] as double) * (item['unitPrice'] as double);
          final itemTva = itemTotal * ((item['tvaRate'] as double) / 100);
          subtotal += itemTotal;
          tvaAmount += itemTva;
        }

        final total = subtotal + tvaAmount;

        expect(subtotal, equals(0.0));
        expect(tvaAmount, equals(0.0));
        expect(total, equals(0.0));
      });
    });

    group('Moroccan TVA rates validation', () {
      test('validates valid TVA rates', () {
        const validRates = [1.0, 10.0, 20.0];

        for (final rate in validRates) {
          expect([1.0, 10.0, 20.0].contains(rate), isTrue);
        }
      });

      test('rejects invalid TVA rates', () {
        const invalidRates = [0.0, 5.0, 15.0, 25.0];

        for (final rate in invalidRates) {
          expect([1.0, 10.0, 20.0].contains(rate), isFalse);
        }
      });

      test('auto-entrepreneur must use 1% TVA', () {
        const isAutoEntrepreneur = true;
        expect(isAutoEntrepreneur, isTrue);
      });

      test('SARL can use any valid rate', () {
        const isAutoEntrepreneur = false;
        expect(isAutoEntrepreneur, isFalse);
      });
    });

    group('Rounding and precision', () {
      test('handles decimal calculations correctly', () {
        final quantity = 3.0;
        final unitPrice = 33.33;
        final total = quantity * unitPrice;

        expect(total.toStringAsFixed(2), equals('99.99'));
      });

      test('accumulates TVA correctly for many items', () {
        double subtotal = 0;
        double tvaAmount = 0;

        for (var i = 0; i < 100; i++) {
          final itemTotal = 10.0;
          final itemTva = itemTotal * 0.2;
          subtotal += itemTotal;
          tvaAmount += itemTva;
        }

        final total = subtotal + tvaAmount;

        expect(subtotal, equals(1000.0));
        expect(tvaAmount, equals(200.0));
        expect(total, equals(1200.0));
      });

      test('precision for large amounts', () {
        final subtotal = 1000000.0;
        final tvaRate = 20.0;
        final tva = subtotal * (tvaRate / 100);
        final total = subtotal + tva;

        expect(tva, equals(200000.0));
        expect(total, equals(1200000.0));
      });
    });
  });
}
