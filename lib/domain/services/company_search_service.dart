import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:http/http.dart' as http;
import 'package:konta/domain/services/log_service.dart';

class CompanyInfo {
  final String name;
  final String? ice;
  final String? rc;
  final String? ifNumber;
  final String? patente;
  final String? cnss;
  final String? address;
  final String? legalForm;
  final String? capital;
  final String? status;
  final List<String> phones;
  final List<String> emails;
  final String? fax;
  final String? detailsUrl;

  CompanyInfo({
    required this.name,
    this.ice,
    this.rc,
    this.ifNumber,
    this.patente,
    this.cnss,
    this.address,
    this.legalForm,
    this.capital,
    this.status,
    this.phones = const [],
    this.emails = const [],
    this.fax,
    this.detailsUrl,
  });
}

class CompanySearchService {
  static final _log = LogService();
  static const _baseUrl = 'https://maroc.welipro.com';

  String decodeCfEmailForTest(String encoded) => _decodeCfEmail(encoded);
  List<String> parseEmailsFromHtmlForTest(String html) {
    final doc = html_parser.parse(html);
    final container = doc.querySelector('div.ml-auto');
    return _extractEmails(container);
  }

  List<String> parsePhonesFromHtmlForTest(String html) {
    final doc = html_parser.parse(html);
    final container = doc.querySelector('div.ml-auto');
    return _extractPhones(container);
  }

  Future<List<CompanyInfo>> search(String query) async {
    _log.info('Service', 'search', data: {'query': query});
    final url = Uri.parse(
      '$_baseUrl/recherche?q=${Uri.encodeComponent(query)}&type=&rs=&cp=1&cp_max=2035272260000&et=&v=',
    );

    _log.info('Service', 'GET ${url.toString()}');
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    );

    if (response.statusCode != 200) {
      _log.error('Service', 'SEARCH_FAILED Status: ${response.statusCode}');
      throw Exception('Failed to search: ${response.statusCode}');
    }

    final results = _parseSearchResults(response.body);
    _log.info('Service', 'Found ${results.length} results for query: $query');
    return results;
  }

  List<CompanyInfo> _parseSearchResults(String html) {
    final document = html_parser.parse(html);
    final results = <CompanyInfo>[];

    final cards = document.querySelectorAll(
      '.card.border-bottom-1.border-bottom-success',
    );

    for (final card in cards) {
      final nameElement = card.querySelector('.card-title a');
      final name = nameElement?.text.trim() ?? '';
      final detailsUrl = nameElement?.attributes['href'];

      final listItems = card.querySelectorAll('li.list-group-item');

      String? ice;
      String? rc;
      String? ifNumber;
      String? address;

      for (final li in listItems) {
        final span = li.querySelector('span.font-weight-semibold');
        if (span == null) continue;

        final label = span.text.trim();
        final div = li.querySelector('div.ml-auto');
        final value = div?.text.trim() ?? '';

        if (label.contains('ICE:')) {
          ice = value;
        } else if (label.contains('Registre du commerce:')) {
          rc = value.split('\n').first.trim();
        } else if (label.contains('Identifiant Fiscal:')) {
          ifNumber = value;
        }
      }

      final addressLi = card.querySelector('li');
      if (addressLi != null) {
        final iconDir = addressLi.querySelector('i.icon-direction');
        if (iconDir != null) {
          address = addressLi.text.trim();
        }
      }

      results.add(
        CompanyInfo(
          name: name,
          ice: ice,
          rc: rc,
          ifNumber: ifNumber,
          address: address,
          detailsUrl: detailsUrl,
        ),
      );
    }

    return results;
  }

  Future<CompanyInfo?> getDetails(CompanyInfo basicInfo) async {
    _log.info('Service', 'getDetails', data: {'name': basicInfo.name});
    if (basicInfo.detailsUrl == null) {
      _log.warn('Service', 'No details URL for: ${basicInfo.name}');
      return null;
    }

    _log.info('Service', 'GET ${basicInfo.detailsUrl!}');
    final response = await http.get(
      Uri.parse(basicInfo.detailsUrl!),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    );

    if (response.statusCode != 200) {
      _log.warn('Service', 'Failed to fetch details: ${response.statusCode}');
      return null;
    }

    final details = _parseDetails(response.body, basicInfo);
    if (details != null) {
      _log.info('Service', 'Details parsed for: ${details.name}');
    }
    return details;
  }

  CompanyInfo? _parseDetails(String html, CompanyInfo basicInfo) {
    final document = html_parser.parse(html);

    final nameElement = document.querySelector(
      '.card-header.bg-teal-400 .card-title',
    );
    final name = nameElement?.text.trim() ?? basicInfo.name;

    final listItems = document.querySelectorAll('li.list-group-item');

    String? ice = basicInfo.ice;
    String? rc = basicInfo.rc;
    String? ifNumber = basicInfo.ifNumber;
    String? patente;
    String? cnss;
    String? capital;
    String? legalForm;
    String? address = basicInfo.address;
    String? status;
    String? fax;
    List<String> phones = [];
    List<String> emails = [];

    for (final li in listItems) {
      final span = li.querySelector('span.font-weight-semibold');
      final icon = li.querySelector('i.icon-direction');

      if (icon != null) {
        address = li.text.trim();
        continue;
      }

      if (span != null) {
        final label = span.text.trim();
        final div = li.querySelector('div.ml-auto');

        if (label.contains('Identifiant Commun de l\'Entreprise')) {
          ice = div?.text.trim() ?? ice;
        } else if (label.contains('Registre du commerce')) {
          final rcText = div?.text.trim() ?? '';
          rc = rcText.split('(').first.trim();
        } else if (label.contains('Identifiant Fiscal')) {
          ifNumber = div?.text.trim() ?? ifNumber;
        } else if (label.contains('Patente')) {
          patente = div?.text.trim();
        } else if (label.contains('CNSS')) {
          cnss = div?.text.trim();
        } else if (label.contains('Capital')) {
          capital = div?.text.trim();
        } else if (label.contains('Forme juridique')) {
          legalForm = div?.text.trim();
        } else if (label.contains('État')) {
          final badge = li.querySelector('.badge');
          status = badge?.text.trim();
        } else if (label.contains('Téléphone')) {
          phones = _extractPhones(div);
        } else if (label.contains('Email')) {
          emails = _extractEmails(div);
        } else if (label.contains('Fax')) {
          fax = div?.text.trim();
        }
      }
    }

    return CompanyInfo(
      name: name,
      ice: ice,
      rc: rc,
      ifNumber: ifNumber,
      patente: patente,
      cnss: cnss,
      address: address,
      legalForm: legalForm,
      capital: capital,
      status: status,
      phones: phones,
      emails: emails,
      fax: fax,
      detailsUrl: basicInfo.detailsUrl,
    );
  }

  List<String> _extractPhones(html_dom.Element? container) {
    if (container == null) return [];

    final phones = <String>[];
    final links = container.querySelectorAll('a[href^="tel:"]');

    for (final a in links) {
      final text = a.text.trim();
      if (text.isNotEmpty) {
        phones.add(text);
      }
    }

    return phones;
  }

  List<String> _extractEmails(html_dom.Element? container) {
    if (container == null) return [];

    final emails = <String>[];

    final cfEmailSpans = container.querySelectorAll('span.__cf_email__');
    for (final span in cfEmailSpans) {
      final cfemail = span.attributes['data-cfemail'];
      if (cfemail != null) {
        final decoded = _decodeCfEmail(cfemail);
        if (decoded.isNotEmpty) {
          emails.add(decoded);
        }
      }
    }

    if (emails.isNotEmpty) return emails;

    final links = container.querySelectorAll('a');
    for (final a in links) {
      final cfemail = a.attributes['data-cfemail'];
      if (cfemail != null) {
        final decoded = _decodeCfEmail(cfemail);
        if (decoded.isNotEmpty) {
          emails.add(decoded);
        }
      }
    }

    if (emails.isEmpty) {
      final text = container.text.trim();
      if (text.isNotEmpty && !text.contains('[email')) {
        return [text];
      }
    }

    return emails;
  }

  String _decodeCfEmail(String encoded) {
    try {
      final hex = encoded.toLowerCase();
      if (hex.length < 4 || hex.length % 2 != 0) return '';

      final key = int.parse(hex.substring(0, 2), radix: 16);
      final result = StringBuffer();

      for (int i = 2; i < hex.length; i += 2) {
        final charCode = int.parse(hex.substring(i, i + 2), radix: 16);
        result.write(String.fromCharCode(charCode ^ key));
      }

      return result.toString();
    } catch (e) {
      return '';
    }
  }
}
