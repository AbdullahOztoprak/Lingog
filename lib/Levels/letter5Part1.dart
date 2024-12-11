import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingogame/Levels/letter5Part2.dart';
import 'package:lingogame/components/grid.dart';
import 'package:lingogame/components/keyboard_row.dart';
import 'package:lingogame/components/timer.dart';
import 'package:lingogame/constants/words.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class Letter5Part1 extends StatefulWidget {
  const Letter5Part1({super.key});

  @override
  State<Letter5Part1> createState() => _Letter5Part1State();
}

class _Letter5Part1State extends State<Letter5Part1> {
  late String _word;

  @override
  void initState() {
    super.initState();
    final r = Random().nextInt(words.length);
    _word = words[r];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<Controller>(context, listen: false);
      controller.setCorrectWord(word: _word);
      controller.resetGame(); // Reset game state when starting a new round
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);

    return Scaffold(
      backgroundColor: const Color(0xff000D31),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Expanded(flex: 4, child: TimerWidget()),
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(55, 5, 55, 5),
              child: const Grid(),
            ),
          ),
          Expanded(
            flex: 5,
            child: controller.gameCompleted
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Reset the game before navigating
                        controller.resetGame();

                        // Go to the next page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Letter5Part2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                        controller.gameWon
                            ? "Tebrikler! ₺${controller.totalEarnings + controller.amount}"
                            : "Tekrar Dene! ₺${controller.totalEarnings + controller.amount}",
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF000D31),
                    child: const Column(
                      children: [
                        KeyboardRow(min: 1, max: 10),
                        KeyboardRow(min: 11, max: 21),
                        KeyboardRow(min: 22, max: 31),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff000D31),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LogoText(),
          _CurrencyContainer(),
        ],
      ),
    );
  }
}

class _LogoText extends StatelessWidget {
  const _LogoText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'LINGO',
            style: TextStyle(
              color: Color(0xFFFBF9F7),
              fontSize: 45,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'G',
            style: TextStyle(
              color: Color(0xFF9F2927),
              fontSize: 45,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyContainer extends StatelessWidget {
  const _CurrencyContainer();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);

    return Container(
      width: 150,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF207A2F),
        border: Border.all(width: 2.5, color: Colors.white),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        '₺${controller.amount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
