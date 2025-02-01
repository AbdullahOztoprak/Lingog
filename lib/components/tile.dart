import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingogame/constants/answer_stages.dart';
import 'package:lingogame/constants/colors.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class Tile extends StatefulWidget {
  const Tile({
    required this.index,
    super.key,
  });

  final int index;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Color _backgroundColor = Colors.transparent;
  Color _borderColor = Colors.transparent;
  late AnswerStage _answerStage;
  String _text = "";

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _borderColor = Colors.white;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateColors(AnswerStage stage) {
    if (stage == AnswerStage.correct) {
      _backgroundColor = correctGreen; // Doğru renk
    } else if (stage == AnswerStage.contains) {
      _backgroundColor = containsYellow; // İçeren renk
    } else if (stage == AnswerStage.incorrect) {
      _backgroundColor = incorrect; // Yanlış renk
    } else if (stage == AnswerStage.falseRed) {
      _backgroundColor = falseRed; // Kötü giriş (falseRed) renk
    } else {
      _backgroundColor = Colors.transparent; // Yanıtlanmamış durumda, renk yok
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (_, notifier, __) {
        // İlk kutu için kontrol
        if (widget.index == 0) {
          _text =
              notifier.correctWord.isNotEmpty ? notifier.correctWord[0] : "";
          _answerStage = AnswerStage.correct; // İlk harf her zaman doğru
        } else if (widget.index < notifier.tilesEntered.length) {
          _text = notifier.tilesEntered[widget.index].letter;
          _answerStage = notifier.tilesEntered[widget.index].answerStage;
        } else {
          // for (int i = 5 * (notifier.currentRow);
          //     i < 5 * (notifier.currentRow + 1);
          //     i++) {
          //   _text = ".";
          // }
          _text = "";
        }

        // Animasyon ve renk güncellemeleri
        if (notifier.checkLine && widget.index < notifier.tilesEntered.length) {
          final delay = widget.index - (notifier.currentRow - 1) * 5;
          Future.delayed(Duration(milliseconds: 300 * delay), () {
            if (mounted) {
              _animationController.forward();
            }
            notifier.checkLine = false;
          });

          _updateColors(_answerStage);
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) {
            double flip = 0;
            if (_animationController.value > 0.50) {
              flip = pi;
            }

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateX(_animationController.value * pi)
                ..rotateX(flip),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: flip > 0 ? _backgroundColor : Colors.transparent,
                  border: Border.all(
                    color: flip > 0 ? Colors.transparent : _borderColor,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _text,
                      style: TextStyle(
                        color: flip > 0 ? Colors.white : Colors.grey[800],
                        fontSize: flip > 0 ? 48 : 36,
                        fontWeight:
                            flip > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
