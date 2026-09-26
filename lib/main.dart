import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

// ============================================================
// APP
// ============================================================

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Calculator',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF29B6F6),
          brightness: Brightness.light,
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

// ============================================================
// CALCULATOR PAGE
// ============================================================

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Layout limits.
  // - Width is capped so the calculator doesn't stretch across a laptop screen.
  // - Height is capped so buttons don't become huge on tall monitors.
  // - Below the minimum height the calculator scrolls instead of overflowing.
  static const double _maxCalculatorWidth = 440;
  static const double _maxCalculatorHeight = 860;
  static const double _minCalculatorHeight = 480;

  String display = '0';
  double firstNumber = 0;
  String operator = '';
  bool newNumber = true;

  // ==========================================================
  // NUMBER
  // ==========================================================

  void numberPressed(String number) {
    setState(() {
      if (newNumber || display == '0' || display == 'Error') {
        display = number;
        newNumber = false;
      } else {
        display += number;
      }
    });
  }

  // ==========================================================
  // DECIMAL
  // ==========================================================

  void decimalPressed() {
    setState(() {
      if (newNumber || display == 'Error') {
        display = '0.';
        newNumber = false;
      } else if (!display.contains('.')) {
        display += '.';
      }
    });
  }

  // ==========================================================
  // OPERATOR
  // ==========================================================

  void operatorPressed(String op) {
    setState(() {
      firstNumber = double.tryParse(display) ?? 0;
      operator = op;
      newNumber = true;
    });
  }

  // ==========================================================
  // CALCULATE
  // ==========================================================

  void calculate() {
    double secondNumber = double.tryParse(display) ?? 0;
    double result = 0;

    switch (operator) {
      case '+':
        result = firstNumber + secondNumber;
        break;

      case '-':
        result = firstNumber - secondNumber;
        break;

      case '×':
        result = firstNumber * secondNumber;
        break;

      case '÷':
        if (secondNumber == 0) {
          setState(() {
            display = 'Error';
            operator = '';
            newNumber = true;
          });
          return;
        }

        result = firstNumber / secondNumber;
        break;

      default:
        return;
    }

    setState(() {
      display = result % 1 == 0 ? result.toInt().toString() : result.toString();

      operator = '';
      newNumber = true;
    });
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  void clear() {
    setState(() {
      display = '0';
      firstNumber = 0;
      operator = '';
      newNumber = true;
    });
  }

  // ==========================================================
  // BACKSPACE
  // ==========================================================

  void backspace() {
    setState(() {
      if (display == 'Error') {
        display = '0';
        newNumber = true;
      } else if (display.length > 1) {
        display = display.substring(0, display.length - 1);
      } else {
        display = '0';
        newNumber = true;
      }
    });
  }

  // ==========================================================
  // KEYBOARD SUPPORT (laptop / desktop / web)
  // ==========================================================

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      calculate();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace) {
      backspace();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) {
      clear();
      return KeyEventResult.handled;
    }

    final char = event.character;
    if (char == null || char.length != 1) return KeyEventResult.ignored;

    if ('0123456789'.contains(char)) {
      numberPressed(char);
      return KeyEventResult.handled;
    }

    switch (char) {
      case '.':
        decimalPressed();
        return KeyEventResult.handled;
      case '+':
        operatorPressed('+');
        return KeyEventResult.handled;
      case '-':
        operatorPressed('-');
        return KeyEventResult.handled;
      case '*':
      case 'x':
      case 'X':
        operatorPressed('×');
        return KeyEventResult.handled;
      case '/':
        operatorPressed('÷');
        return KeyEventResult.handled;
      case '=':
        calculate();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  // ==========================================================
  // BUTTON HELPERS
  // ==========================================================

  Widget calculatorButton(
    String text, {
    VoidCallback? onPressed,
    bool operatorButton = false,
    bool equalButton = false,
    bool clearButton = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: _AnimatedCalculatorButton(
          text: text,
          onPressed: onPressed,
          operatorButton: operatorButton,
          equalButton: equalButton,
          clearButton: clearButton,
        ),
      ),
    );
  }

  Widget _digit(String n) =>
      calculatorButton(n, onPressed: () => numberPressed(n));

  Widget _op(String op) => calculatorButton(
        op,
        onPressed: () => operatorPressed(op),
        operatorButton: true,
      );

  Widget _row(List<Widget> children) {
    return Expanded(child: Row(children: children));
  }

  // ==========================================================
  // DISPLAY
  // ==========================================================

  Widget _buildDisplay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFB3E5FC), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2629B6F6), // primary blue @ ~15% opacity
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // OPERATOR
            SizedBox(
              height: 24,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: operator.isNotEmpty
                    ? Text(
                        operator,
                        key: ValueKey(operator),
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),

            const SizedBox(height: 3),

            // DISPLAY NUMBER
            // Flexible + FittedBox: the number shrinks to fit BOTH the
            // available width and height, so it can never overflow.
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: FittedBox(
                  key: ValueKey(display),
                  fit: BoxFit.scaleDown,
                  child: Text(
                    display,
                    style: const TextStyle(
                      color: Color(0xFF0277BD),
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // KEYPAD
  // ==========================================================

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          _row([
            calculatorButton('AC', onPressed: clear, clearButton: true),
            calculatorButton('⌫', onPressed: backspace, operatorButton: true),
            _op('÷'),
            _op('×'),
          ]),
          _row([_digit('7'), _digit('8'), _digit('9'), _op('-')]),
          _row([_digit('4'), _digit('5'), _digit('6'), _op('+')]),
          _row([
            _digit('1'),
            _digit('2'),
            _digit('3'),
            calculatorButton('=', onPressed: calculate, equalButton: true),
          ]),
          _row([
            _digit('0'),
            calculatorButton('.', onPressed: decimalPressed),
            // Empty spaces to keep alignment
            const Spacer(),
            const Spacer(),
          ]),
        ],
      ),
    );
  }

  // ==========================================================
  // CALCULATOR (display + keypad) for a given height
  // ==========================================================

  Widget _buildCalculator(double height) {
    // Display takes ~24% of the height, but never too small / too big.
    final displayHeight = (height * 0.24).clamp(120.0, 220.0).toDouble();

    return Column(
      children: [
        SizedBox(height: displayHeight, child: _buildDisplay()),
        Expanded(child: _buildKeypad()),
      ],
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),

        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFFE1F5FE),
          centerTitle: true,
          title: const Text(
            'Calculator',
            style: TextStyle(
              color: Color(0xFF0277BD),
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _maxCalculatorWidth,
                maxHeight: _maxCalculatorHeight,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final needsScroll =
                      constraints.maxHeight < _minCalculatorHeight;
                  final height = math.max(
                    constraints.maxHeight,
                    _minCalculatorHeight,
                  );

                  final content = SizedBox(
                    width: double.infinity,
                    height: height,
                    child: _buildCalculator(height),
                  );

                  // Very short windows (e.g. phone in landscape):
                  // scroll instead of showing the overflow stripes.
                  return needsScroll
                      ? SingleChildScrollView(child: content)
                      : content;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ANIMATED CALCULATOR BUTTON
// ============================================================

class _AnimatedCalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool operatorButton;
  final bool equalButton;
  final bool clearButton;

  const _AnimatedCalculatorButton({
    required this.text,
    required this.onPressed,
    required this.operatorButton,
    required this.equalButton,
    required this.clearButton,
  });

  @override
  State<_AnimatedCalculatorButton> createState() =>
      _AnimatedCalculatorButtonState();
}

class _AnimatedCalculatorButtonState extends State<_AnimatedCalculatorButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // ---------------- COLORS ----------------
    final Color background = widget.equalButton
        ? const Color(0xFF29B6F6)
        : widget.operatorButton
            ? const Color(0xFFE1F5FE)
            : widget.clearButton
                ? const Color(0xFFFFEBEE)
                : Colors.white;

    final Color foreground = widget.equalButton
        ? Colors.white
        : widget.operatorButton
            ? const Color(0xFF0288D1)
            : widget.clearButton
                ? const Color(0xFFE53935)
                : const Color(0xFF263238);

    final Color border = widget.equalButton
        ? Colors.transparent
        : widget.operatorButton
            ? const Color(0xFF81D4FA)
            : widget.clearButton
                ? const Color(0xFFFFCDD2)
                : const Color(0xFFE0F2F7);

    final bool isWordLabel = widget.text == 'AC' || widget.text == '⌫';

    return AnimatedScale(
      scale: isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: SizedBox.expand(
        child: Material(
          color: background,
          elevation: widget.equalButton ? 5 : 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: border, width: 1),
          ),
          child: InkWell(
            // Keep keyboard focus on the page so typing keeps working.
            canRequestFocus: false,
            onTap: widget.onPressed,
            onHighlightChanged: (value) {
              setState(() {
                isPressed = value;
              });
            },
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Font scales with the button size:
                  // small on phones, larger on laptops.
                  final shortestSide = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final base = (shortestSide * 0.36).clamp(16.0, 34.0);
                  final fontSize = isWordLabel ? base * 0.8 : base;

                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}