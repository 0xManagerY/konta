class ArabicNumberToWords {
  static const _units = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
    'عشرة',
    'أحد عشر',
    'اثنا عشر',
    'ثلاثة عشر',
    'أربعة عشر',
    'خمسة عشر',
    'ستة عشر',
    'سبعة عشر',
    'ثمانية عشر',
    'تسعة عشر',
  ];

  static const _tens = [
    '',
    'عشرة',
    'عشرون',
    'ثلاثون',
    'أربعون',
    'خمسون',
    'ستون',
    'سبعون',
    'ثمانون',
    'تسعون',
  ];

  static const _hundreds = [
    '',
    'مائة',
    'مائتان',
    'ثلاثمائة',
    'أربعمائة',
    'خمسمائة',
    'ستمائة',
    'سبعمائة',
    'ثمانمائة',
    'تسعمائة',
  ];

  static String convert(double number) {
    if (number == 0) return 'صفر درهم';

    final parts = number.toStringAsFixed(2).split('.');
    final intPart = int.parse(parts[0]);
    final decPart = int.parse(parts[1]);

    final buffer = StringBuffer();

    if (intPart > 0) {
      buffer.write(_convertInteger(intPart));
      buffer.write(intPart == 1 ? ' درهم' : ' درهم');
    }

    if (decPart > 0) {
      if (intPart > 0) buffer.write(' و ');
      buffer.write(_convertInteger(decPart));
      buffer.write(decPart == 1 ? ' سنتيم' : ' سنتيم');
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

    final tens = number ~/ 10;
    final units = number % 10;

    if (units == 0) return _tens[tens];

    final unitsWord = units == 2 ? 'اثنتان' : _units[units];
    return '$unitsWord و ${_tens[tens]}';
  }

  static String _convertHundreds(int number) {
    final hundreds = number ~/ 100;
    final remainder = number % 100;

    final buffer = StringBuffer();
    buffer.write(_hundreds[hundreds]);

    if (remainder > 0) {
      buffer.write(' و ');
      buffer.write(_convertTens(remainder));
    }

    return buffer.toString();
  }

  static String _convertThousands(int number) {
    final thousands = number ~/ 1000;
    final remainder = number % 1000;

    final buffer = StringBuffer();

    if (thousands == 1) {
      buffer.write('ألف');
    } else if (thousands == 2) {
      buffer.write('ألفان');
    } else if (thousands < 11) {
      buffer.write('${_units[thousands]} آلاف');
    } else {
      buffer.write('${_convertInteger(thousands)} ألف');
    }

    if (remainder > 0) {
      buffer.write(' و ');
      buffer.write(_convertInteger(remainder));
    }

    return buffer.toString();
  }

  static String _convertMillions(int number) {
    final millions = number ~/ 1000000;
    final remainder = number % 1000000;

    final buffer = StringBuffer();

    if (millions == 1) {
      buffer.write('مليون');
    } else if (millions == 2) {
      buffer.write('مليونان');
    } else if (millions < 11) {
      buffer.write('${_units[millions]} ملايين');
    } else {
      buffer.write('${_convertInteger(millions)} مليون');
    }

    if (remainder > 0) {
      buffer.write(' و ');
      buffer.write(_convertInteger(remainder));
    }

    return buffer.toString();
  }

  static String _convertBillions(int number) {
    final billions = number ~/ 1000000000;
    final remainder = number % 1000000000;

    final buffer = StringBuffer();

    if (billions == 1) {
      buffer.write('مليار');
    } else if (billions == 2) {
      buffer.write('ملياران');
    } else if (billions < 11) {
      buffer.write('${_units[billions]} مليارات');
    } else {
      buffer.write('${_convertInteger(billions)} مليار');
    }

    if (remainder > 0) {
      buffer.write(' و ');
      buffer.write(_convertInteger(remainder));
    }

    return buffer.toString();
  }
}
