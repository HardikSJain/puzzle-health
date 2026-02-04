import 'package:logger/logger.dart';

import '../utils/logger_utils.dart';

LoggerUtil logData = LoggerUtil(
  printer: PrettyPrinter(
    methodCount: 0,
    lineLength: 150,
    dateTimeFormat: DateTimeFormat.dateAndTime,
    printEmojis: false,
  ),
);
