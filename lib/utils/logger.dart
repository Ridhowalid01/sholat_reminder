import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  level: kReleaseMode ? Level.off : Level.debug,
);