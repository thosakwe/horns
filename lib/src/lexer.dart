import 'dart:collection';
import 'package:string_scanner/string_scanner.dart';
import 'syntax_error.dart';
import 'lexer_mode.dart';
import 'token.dart';

class Lexer<TokenType> {
  final Queue<LexerMode<TokenType>> _modeStack = new Queue();

  final Map<String, LexerMode<TokenType>> modes = {
    'DEFAULT_MODE': new LexerMode<TokenType>()
  };

  LexerMode<TokenType> get defaultMode => modes['DEFAULT_MODE'];

  void addMode(String name, void Function(LexerMode<TokenType>) f) {
    var mode = modes[name] = new LexerMode<TokenType>();
    f(mode);
  }

  void popMode() {
    if (_modeStack.isEmpty)
      throw new StateError('Cannot call `popMode` when the stack is empty.');
    _modeStack.removeFirst();
  }

  void pushMode(String name) {
    if (!modes.containsKey(name))
      throw new ArgumentError('No lexer mode named `$name`.');
    _modeStack.addFirst(modes[name]);
  }

  LexerResult<TokenType> scan(SpanScanner scanner) {
    var tokens = <Token<TokenType>>[];
    var syntaxErrors = <SyntaxError>[];
    LineScannerState _errState;

    _modeStack
      ..clear()
      ..addFirst(defaultMode);

    void flush() {
      if (_errState != null) {
        var span = scanner.spanFrom(_errState);
        syntaxErrors.add(new SyntaxError(SyntaxErrorSeverity.error, span,
            'Unexpected input "${span.text}".'));
        _errState = null;
      }
    }

    while (!scanner.isDone) {
      var token = _modeStack.first.scan(this, scanner);

      if (token == null) {
        _errState ??= scanner.state;
        scanner.readChar();
      } else {
        if (token is! SkipToken) {
          flush();
          tokens.add(token);
        }
      }
    }

    flush();

    return new LexerResult(new UnmodifiableListView(tokens), syntaxErrors);
  }
}

class LexerResult<TokenType> {
  final UnmodifiableListView<Token<TokenType>> tokens;
  final List<SyntaxError> syntaxErrors;

  LexerResult(this.tokens, this.syntaxErrors);
}
