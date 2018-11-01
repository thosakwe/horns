import 'package:source_span/source_span.dart';

class Token<TokenType> {
  final TokenType type;
  final FileSpan span;
  final Match match;

  const Token(this.type, this.span, this.match);

  @override
  String toString() => '${span.start.toolString}: "${span.text}" => $type';
}

class SkipToken<TokenType> extends Token<TokenType> {
  const SkipToken(FileSpan span, Match match) : super(null, span, match);
}
