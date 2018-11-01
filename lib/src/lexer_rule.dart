import 'package:string_scanner/string_scanner.dart';
import 'lexer.dart';
import 'token.dart';

class LexerRule<TokenType> {
  final Token<TokenType> Function(Lexer<TokenType>, SpanScanner) callback;
  void Function(Lexer<TokenType>) _predicate;

  LexerRule(this.callback);

  void predicate(Lexer<TokenType> lexer) {
    if (_predicate != null) _predicate(lexer);
  }

  LexerRule<TokenType> pushMode(String name) =>
      this.._predicate = (lexer) => lexer.pushMode(name);

  LexerRule<TokenType> popMode() =>
      this.._predicate = (lexer) => lexer.popMode();
}

LexerRule<TokenType> emit<TokenType>(TokenType type) {
  return new LexerRule<TokenType>((lexer, scanner) {
    return new Token(type, scanner.lastSpan, scanner.lastMatch);
  });
}

LexerRule<TokenType> skip<TokenType>() {
  return new LexerRule<TokenType>((lexer, scanner) {
    return new SkipToken(scanner.lastSpan, scanner.lastMatch);
  });
}
