import 'parser.dart';
import 'parser_rule.dart';
import 'token.dart';

class PrecedenceParser<TokenType, T> extends ParserRule<TokenType, T> {
  PrecedenceParser() : super(null);

  @override
  T Function(Parser<TokenType>) get f => _parse;

  void prefix(
      int precedence, T Function(Parser<TokenType>, Token<TokenType>) f) {}

  void infix(
      int precedence, T Function(Parser<TokenType>, Token<TokenType>, T) f) {}

  void postfix(int precedence, T Function(Parser<TokenType>, T) f) {
    infix(precedence, (parser, token, left) => f(parser, left));
  }

  T _parse(Parser<TokenType> parser) {}
}
