import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw const FileSystemException('SUPABASE_URL not found in .env');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];
    if (key == null || key.isEmpty) {
      throw const FileSystemException(
        'SUPABASE_PUBLISHABLE_KEY not found in .env',
      );
    }
    return key;
  }

  static String get supabaseServiceKey {
    final key = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (key == null || key.isEmpty) {
      throw const FileSystemException(
        'SUPABASE_SERVICE_ROLE_KEY not found in .env',
      );
    }
    return key;
  }

  static String get supabasePat {
    final pat = dotenv.env['SUPABASE_PAT'];
    if (pat == null || pat.isEmpty) {
      throw const FileSystemException('SUPABASE_PAT not found in .env');
    }
    return pat;
  }
}
