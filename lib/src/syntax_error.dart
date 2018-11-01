import 'package:source_span/source_span.dart';

class SyntaxError extends Error {
  final SyntaxErrorSeverity severity;
  final FileSpan span;
  final String message;

  SyntaxError(this.severity, this.span, this.message);

  @override
  String toString() =>
      '${severityToString(severity)}: ${span.start.toolString}: $message';
}

String severityToString(SyntaxErrorSeverity severity) {
  switch (severity) {
    case SyntaxErrorSeverity.info:
      return 'info';
    case SyntaxErrorSeverity.hint:
      return 'hint';
    case SyntaxErrorSeverity.warning:
      return 'warning';
    case SyntaxErrorSeverity.error:
      return 'error';
    default:
      throw new ArgumentError();
  }
}

enum SyntaxErrorSeverity { info, hint, warning, error }
