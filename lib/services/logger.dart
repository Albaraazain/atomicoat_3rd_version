// lib/services/logger.dart

import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    // In a real application, you might want to write logs to a file or send them to a server
    print('${DateTime.now()}: $message');
  }
}