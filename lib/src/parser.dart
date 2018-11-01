import 'lexer.dart';
import 'parser_rule.dart';
import 'token.dart';

class Parser<TokenType> {
  final Map<String, ParserRule<TokenType, dynamic>> rules = {};
  final LexerResult<TokenType> lexerResult;

  Parser(this.lexerResult);

  T parse<T>(String name) {
    
  }

  bool next(TokenType type) {}

  Token<TokenType> consume() {}
}
