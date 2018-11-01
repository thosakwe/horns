import 'lexer.dart';
import 'parser_rule.dart';
import 'syntax_error.dart';
import 'token.dart';

class Parser<TokenType> {
  final Map<String, ParserRule<TokenType, dynamic>> rules = {};
  final LexerResult<TokenType> lexerResult;
  final List<SyntaxError> syntaxErrors = [];
  var _index = 0;

  Parser(this.lexerResult) {
    syntaxErrors.addAll(lexerResult.syntaxErrors);
  }

  T parse<T>(String name, {int precedence: 0}) {
    if (!rules.containsKey(name))
      throw new ArgumentError.value(name, 'name', 'no such rule');
    var rule = rules[name];

    if (!rule.viable(this)) {
      return null;
    } else {
      return rule.f(this) as T;
    }
  }

  bool get isDone => _index >= lexerResult.tokens.length - 1;

  bool next(TokenType type) => peek()?.type == type;

  Token<TokenType> peek() => isDone ? null : lexerResult.tokens[_index + 1];

  Token<TokenType> consume() {
    var token = peek();
    _index++;
    return token;
  }
}
