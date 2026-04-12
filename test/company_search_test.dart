import 'package:flutter_test/flutter_test.dart';
import 'package:konta/domain/services/company_search_service.dart';

void main() {
  group('Cloudflare Email Decoding', () {
    test('decode cfemail correctly', () {
      final service = CompanySearchService();

      final email1 = service.decodeCfEmailForTest(
        'cbaebabea2bba2aeb98ba6aea5aab9aae5a6aa',
      );
      expect(email1, equals('equipier@menara.ma'));

      final email2 = service.decodeCfEmailForTest(
        '7e1b0f0b170e171b0c4e4e4e4f3e19131f1712501d1113',
      );
      expect(email2, equals('equipier0001@gmail.com'));
    });

    test('parse emails from HTML', () {
      final html = '''
        <li class="list-group-item">
          <span class="font-weight-semibold">Email:</span>
          <div class="ml-auto">
            <a href="/cdn-cgi/l/email-protection#3e5b4f4b574e575b4c7e535b505f4c5f10535f">
              <span class="__cf_email__" data-cfemail="cbaebabea2bba2aeb98ba6aea5aab9aae5a6aa">[email&#160;protected]</span>
            </a>
            <br>
            <a href="/cdn-cgi/l/email-protection#365347435f465f53440606060776515b575f5a1855595b">
              <span class="__cf_email__" data-cfemail="7e1b0f0b170e171b0c4e4e4e4f3e19131f1712501d1113">[email&#160;protected]</span>
            </a>
          </div>
        </li>
      ''';

      final service = CompanySearchService();
      final emails = service.parseEmailsFromHtmlForTest(html);

      expect(emails.length, equals(2));
      expect(emails[0], equals('equipier@menara.ma'));
      expect(emails[1], equals('equipier0001@gmail.com'));
    });
  });

  group('Phone Number Extraction', () {
    test('parse multiple phone numbers from HTML', () {
      final html = '''
        <li class="list-group-item">
          <span class="font-weight-semibold">Téléphone:</span>
          <div class="ml-auto">
            <a href="tel:+212522850788">+212522850788</a>
            <br>
            <a href="tel:+212522284189">+212522284189</a>
            <br>
            <a href="tel:+212522283465">+212522283465</a>
            <br>
            <a href="tel:+212522280812">+212522280812</a>
          </div>
        </li>
      ''';

      final service = CompanySearchService();
      final phones = service.parsePhonesFromHtmlForTest(html);

      expect(phones.length, equals(4));
      expect(phones[0], equals('+212522850788'));
      expect(phones[1], equals('+212522284189'));
      expect(phones[2], equals('+212522283465'));
      expect(phones[3], equals('+212522280812'));
    });
  });
}
