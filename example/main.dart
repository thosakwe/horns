import 'package:cli_repl/cli_repl.dart';
import 'package:horns/horns.dart';
import 'package:string_scanner/string_scanner.dart';

main() async {
  var repl = new Repl(prompt: '>> ');

  await for (var line in repl.runAsync()) {
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var lex = mathLexer.scan(scanner);

    if (lex.syntaxErrors.isNotEmpty) {
      lex.syntaxErrors.forEach(print);
    } else {
      var parser = mathParser(lex);
      var term = parser.parse('term');
      print(term);
    }
  }
}

final mathLexer = new Lexer<TokenType>()
  ..defaultMode.rules.addAll({
    new RegExp(r'[ \n\r\t]+'): skip(),
    '(': emit(TokenType.PAREN_L).pushMode('DEFAULT_MODE'),
    ')': emit(TokenType.PAREN_R).popMode(),
    '*': emit(TokenType.TIMES),
    '/': emit(TokenType.DIV),
    '%': emit(TokenType.MOD),
    '+': emit(TokenType.PLUS),
    '-': emit(TokenType.MINUS),
    new RegExp(r'-?[0-9]+(\.[0-9]+)?'): emit(TokenType.NUM)
  });

Parser<TokenType> mathParser(LexerResult<TokenType> result) {
  double Function(Parser<TokenType>, Token<TokenType>, double) op(
      double Function(double, double) f) {
    return (p, token, left) {
      var right = p.parse<double>('term');

      if (right == null) {
        p.syntaxErrors.add(new SyntaxError(SyntaxErrorSeverity.error,
            token.span, "Missing term after operator `${token.span.text}`."));
      } else {
        return f(left, right);
      }
    };
  }

  return new Parser<TokenType>(result)
    ..rules.addAll({
      'term': new PrecedenceParser<TokenType, double>()
        ..prefix(TokenType.NUM, (_, token) => double.parse(token.span.text))
        ..prefix(TokenType.PAREN_L, (p, token) {
          var expr = p.parse<double>('term');
          if (expr == null) {
            p.syntaxErrors.add(new SyntaxError(SyntaxErrorSeverity.error,
                token.span, "Missing term after `)`."));
          } else {
            return expr;
          }
        })
        ..infix(TokenType.TIMES, op((l, r) => l * r))
        ..infix(TokenType.DIV, op((l, r) => l / r))
        ..infix(TokenType.MOD, op((l, r) => l % r))
        ..infix(TokenType.PLUS, op((l, r) => l + r))
        ..infix(TokenType.MINUS, op((l, r) => l - r))
    });
}

enum TokenType { PAREN_L, PAREN_R, TIMES, DIV, MOD, PLUS, MINUS, NUM }
