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
      lex.tokens.forEach(print);
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
  return new Parser(result)
    ..rules.addAll({
      'term': new PrecedenceParser<TokenType, double>(),
    });
}

enum TokenType { PAREN_L, PAREN_R, TIMES, DIV, MOD, PLUS, MINUS, NUM }
