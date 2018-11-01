import 'parser.dart';
import 'parser_rule.dart';
import 'token.dart';

class PrecedenceParser<TokenType, T> extends ParserRule<TokenType, T> {
  PrecedenceParser() : super(null);

  var _prefix = <_Prefix<TokenType, T>>[];
  var _infix = <_Infix<TokenType, T>>[];

  int get highestPrecedence => _infix.isEmpty
      ? 0
      : _infix.reduce((a, b) => b.precedence > a.precedence ? b : a).precedence;

  @override
  T Function(Parser<TokenType>) get f => _parse;

  void prefixWithViable(T Function(Parser<TokenType>) f,
      bool Function(Parser<TokenType>) viable) {
    viable ??= (_) => true;
    _prefix.add(new _Prefix(f, viable));
  }

  void prefix(
      TokenType type, T Function(Parser<TokenType>, Token<TokenType>) f) {
    prefixWithViable((p) => f(p, p.consume()), (p) => p.next(type));
  }

  void infixWithViable(bool Function(Parser<TokenType>) viable,
      T Function(Parser<TokenType>, T) f,
      {int precedence}) {
    precedence ??= highestPrecedence + 1;
    _infix.add(new _Infix(precedence, f, viable));
  }

  void infix(
      TokenType type, T Function(Parser<TokenType>, Token<TokenType>, T) f,
      {int precedence}) {
    infixWithViable(viable, (p, l) => f(p, p.consume(), l),
        precedence: precedence);
  }

  int _nextPrecedence(Parser<TokenType> parser) {
    var next = _infix.firstWhere((p) => p.viable(parser), orElse: () => null);
    return next?.precedence ?? 0;
  }

  T _parse(Parser<TokenType> parser, [int precedence = 0]) {
    // Find the first prefix rule that is viable to be parsed here.
    var prefix =
        _prefix.firstWhere((p) => p.viable(parser), orElse: () => null);
    if (prefix == null) return null;

    var left = prefix.f(parser);

    while (precedence < _nextPrecedence(parser)) {
      var next = _infix.firstWhere((p) => p.viable(parser), orElse: () => null);
      left = next.f(parser, left);
    }

    return left;
  }
}

class _Prefix<TokenType, T> {
  final T Function(Parser<TokenType>) f;
  final bool Function(Parser<TokenType>) viable;

  _Prefix(this.f, this.viable);
}

class _Infix<TokenType, T> {
  final int precedence;
  final T Function(Parser<TokenType>, T) f;
  final bool Function(Parser<TokenType>) viable;

  _Infix(this.precedence, this.f, this.viable);
}
