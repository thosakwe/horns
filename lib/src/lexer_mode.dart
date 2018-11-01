import 'package:string_scanner/string_scanner.dart';
import 'lexer.dart';
import 'lexer_rule.dart';
import 'token.dart';

class LexerMode<TokenType> {
  final Map<Pattern, LexerRule<TokenType>> rules = {};

  Token<TokenType> scan(Lexer<TokenType> lexer, SpanScanner scanner) {
    var potential = <Token<TokenType>>[];
    var map = <Token<TokenType>, LexerRule<TokenType>>{};
    for (var pair in rules.entries) {
      var pattern = pair.key, rule = pair.value;

      if (scanner.matches(pattern)) {
        var token = rule.callback(lexer, scanner);
        if (token != null) {
          potential.add(token);
          map[token] = rule;
        }
      }
    }

    potential.sort((a, b) => b.span.text.length.compareTo(a.span.text.length));

    if (potential.isEmpty) {
      return null;
    } else {
      var token = potential.first;
      scanner.scan(token.span.text);
      map[token]?.predicate(lexer);
      return token;
    }
  }
}
