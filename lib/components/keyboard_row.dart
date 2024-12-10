import 'package:flutter/material.dart';
import 'package:lingogame/constants/colors.dart';
import 'package:lingogame/constants/keyboardKeyState.dart';
import 'package:lingogame/constants/keys_map.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class KeyboardRow extends StatelessWidget {
  const KeyboardRow({
    required this.min,
    required this.max,
    super.key,
  });

  final int min, max;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<Controller>(
      builder: (_, notifier, __) {
        return IgnorePointer(
          ignoring: notifier.gameCompleted,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: keysMap.entries.map((e) {
              int index = keysMap.keys.toList().indexOf(e.key) + 1;

              if (index >= min && index <= max) {
                // Harfin rengini al
                Color color = _getColor(e.key, notifier);

                return Padding(
                  padding: EdgeInsets.all(size.width * 0.006),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: e.key == 'ENTER' || e.key == 'BACK'
                          ? size.width * 0.135
                          : size.width * 0.075,
                      height: size.height * 0.065,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: size.width * 0.003, // Stroke width
                            color: Colors.white, // Stroke color
                          ),
                        ),
                        child: Material(
                          color:
                              Colors.transparent, // Transparent to show stroke
                          child: InkWell(
                            onTap: () {
                              notifier.setKeyTapped(value: e.key);
                            },
                            child: Center(
                              child: e.key == 'BACK'
                                  ? Icon(
                                      Icons.backspace_outlined,
                                      size: size.width * 0.05,
                                      color: Colors.black,
                                    )
                                  : Text(
                                      e.key,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.04,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            }).toList(),
          ),
        );
      },
    );
  }

  // Harfin rengini belirle
  Color _getColor(String letter, Controller notifier) {
    final keyState = notifier.getKeyState(letter); // Harfin durumunu al

    // Duruma göre renk döndür
    switch (keyState) {
      case KeyboardKeyState.kcorrect:
        return correctGreen;
      case KeyboardKeyState.kcontains:
        return containsYellow;
      case KeyboardKeyState.kincorrect:
        return falseRed;
      default:
        return incorrect; // Eğer state knotAnswered ise veya başka bir durumda ise
    }
  }
}
