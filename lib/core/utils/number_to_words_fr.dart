class FrenchNumberToWords {
  static const _units = [
    '', // 0
    'un', // 1
    'deux', // 2
    'trois', // 3
    'quatre', // 4
    'cinq', // 5
    'six', // 6
    'sept', // 7
    'huit', // 8
    'neuf', // 9
    'dix', // 10
    'onze', // 11
    'douze', // 12
    'treize', // 13
    'quatorze', // 14
    'quinze', // 15
    'seize', // 16
    'dix-sept', // 17
    'dix-huit', // 18
    'dix-neuf', // 19
  ];

  static const _tens = [
    '',
    '',
    'vingt',
    'trente',
    'quarante',
    'cinquante',
    'soixante',
    'soixante',
    'quatre-vingt',
    'quatre-vingt',
  ];

  static String convert(double number) {
    if (number == 0) return 'zéro dirham';

    final parts = number.toStringAsFixed(2).split('.');
    final intPart = int.parse(parts[0]);
    final decPart = int.parse(parts[1]);

    final buffer = StringBuffer();

    if (intPart > 0) {
      buffer.write(_convertInteger(intPart));
      buffer.write(intPart == 1 ? ' dirham' : ' dirhams');
    }

    if (decPart > 0) {
      if (intPart > 0) buffer.write(' et ');
      buffer.write(_convertInteger(decPart));
      buffer.write(decPart == 1 ? ' centime' : ' centimes');
    }

    return buffer.toString();
  }

  static String _convertInteger(int number) {
    if (number < 20) return _units[number];
    if (number < 100) return _convertTens(number);
    if (number < 1000) return _convertHundreds(number);
    if (number < 1000000) return _convertThousands(number);
    if (number < 1000000000) return _convertMillions(number);
    return _convertBillions(number);
  }

  static String _convertTens(int number) {
    if (number < 20) return _units[number];

    final tensIndex = number ~/ 10;
    final units = number % 10;
    final tensWord = _tens[tensIndex];

    if (tensIndex == 7 || tensIndex == 9) {
      final specialUnits = number - (tensIndex * 10);
      if (specialUnits == 1) {
        return '$tensWord et ${_units[specialUnits + 10]}';
      }
      return '$tensWord-${_units[specialUnits + 10]}';
    }

    if (units == 0) {
      return tensIndex == 8 ? '$tensWord-s' : tensWord;
    }

    if (units == 1 && tensIndex != 8) {
      return '$tensWord et ${_units[units]}';
    }

    return '$tensWord-${_units[units]}';
  }

  static String _convertHundreds(int number) {
    final hundreds = number ~/ 100;
    final remainder = number % 100;

    final buffer = StringBuffer();

    if (hundreds > 1) {
      buffer.write('${_units[hundreds]} ');
    }

    if (hundreds > 0) {
      buffer.write('cent');
      if (hundreds > 1 && remainder == 0) {
        buffer.write('s');
      }
    }

    if (remainder > 0) {
      if (hundreds > 0) buffer.write(' ');
      buffer.write(_convertTens(remainder));
    }

    return buffer.toString();
  }

  static String _convertThousands(int number) {
    final thousands = number ~/ 1000;
    final remainder = number % 1000;

    final buffer = StringBuffer();

    if (thousands == 1) {
      buffer.write('mille');
    } else {
      buffer.write('${_convertInteger(thousands)} mille');
    }

    if (remainder > 0) {
      buffer.write(' ${_convertTens(remainder)}');
    }

    return buffer.toString();
  }

  static String _convertMillions(int number) {
    final millions = number ~/ 1000000;
    final remainder = number % 1000000;

    final buffer = StringBuffer();
    buffer.write('${_convertInteger(millions)} million');
    if (millions > 1) buffer.write('s');

    if (remainder > 0) {
      buffer.write(' ${_convertInteger(remainder)}');
    }

    return buffer.toString();
  }

  static String _convertBillions(int number) {
    final billions = number ~/ 1000000000;
    final remainder = number % 1000000000;

    final buffer = StringBuffer();
    buffer.write('${_convertInteger(billions)} milliard');
    if (billions > 1) buffer.write('s');

    if (remainder > 0) {
      buffer.write(' ${_convertInteger(remainder)}');
    }

    return buffer.toString();
  }
}
