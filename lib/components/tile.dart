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
    switch (stage) {
      case AnswerStage.correct:
        _backgroundColor = correctGreen; // Doğru renk
        break;
      case AnswerStage.contains:
        _backgroundColor = containsYellow; // İçeren renk
        break;
      case AnswerStage.incorrect:
        _backgroundColor = incorrect; // Yanlış renk
        break;
      case AnswerStage.falseRed:
        _backgroundColor = falseRed; // Kötü giriş (falseRed) renk
        break;
      case AnswerStage.notAnswered:
      default:
        _backgroundColor =
            Colors.transparent; // Yanıtlanmamış durumda, renk yok
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (_, notifier, __) {
        if (widget.index < notifier.tilesEntered.length) {
          _text = notifier.tilesEntered[widget.index].letter;
          _answerStage = notifier.tilesEntered[widget.index].answerStage;

          // Animasyonu tetiklemek için ENTER basıldığında hepsi dönecek
          if (notifier.enterTapped == true &&
              notifier.notEnoughLetters == false) {
            final delay = widget.index - (notifier.currentRow - 1) * 5;
            Future.delayed(Duration(milliseconds: 300 * delay), () {
              if (mounted) {
                _animationController.forward();
              }
            });
            notifier.checkLine = false;
          }

          _updateColors(_answerStage);

          return AnimatedBuilder(
            animation: _animationController,
            builder: (_, child) {
              double flip = 0;
              if (_animationController.value > 0.5) {
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
                      child: flip > 0
                          ? Text(
                              _text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              _text,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 36,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _borderColor,
              ),
            ),
          );
        }
      },
    );
  }
}
