import 'parser.dart';
import 'token.dart';

class ParserRule<TokenType, T> {
  final T Function(Parser<TokenType>) f;

  ParserRule(this.f, {bool Function(Parser<TokenType>) viable})
      : this.viable = viable ?? ((_) => true);

  final bool Function(Parser<TokenType>) viable;
}

ParserRule<TokenType, T> iff<TokenType, T>(
    bool Function(Parser<TokenType>) predicate, ParserRule<TokenType, T> rule) {
  return new ParserRule<TokenType, T>(rule.f,
      viable: (parser) => predicate(parser) && rule.viable(parser));
}

ParserRule<TokenType, T> consume<TokenType, T>(
    TokenType type, T Function(Parser<TokenType>, Token<TokenType>) f) {
  return new ParserRule<TokenType, T>((parser) {
    return f(parser, parser.consume());
  }, viable: (parser) => parser.next(type));
}
