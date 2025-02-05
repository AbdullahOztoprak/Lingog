import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingogame/Levels/letter7Part1.dart';
import 'package:lingogame/components/grid7.dart';
import 'package:lingogame/components/keyboard_row.dart';
import 'package:lingogame/components/timer.dart';
import 'package:lingogame/constants/words.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class Letter7Part2 extends StatefulWidget {
  final int wordLength; // ✅ Kelime uzunluğu

  const Letter7Part2({super.key, required this.wordLength});

  @override
  State<Letter7Part2> createState() => _Letter7Part2State();
}

class _Letter7Part2State extends State<Letter7Part2> {
  late String _word;

  @override
  void initState() {
    super.initState();

    // ✅ Seçilen uzunlukta bir kelime al
    final wordList =
        words7.where((word) => word.length == widget.wordLength).toList();

    if (wordList.isNotEmpty) {
      final r = Random().nextInt(wordList.length);
      _word = wordList[r];
    } else {
      _word = "PARASAL"; // Eğer kelime yoksa varsayılan bir değer koy
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<Controller>(context, listen: false);
      controller.setWordLength(widget.wordLength);
      controller.resetGame();
      controller.setCorrectWord(word: _word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000D31),
      appBar: _buildAppBar(size),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          const Expanded(flex: 4, child: TimerWidget()),
          Expanded(
            flex: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: const Grid7(),
            ),
          ),
          Expanded(
            flex: 5,
            child: controller.gameCompleted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!controller.gameWon)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                          child: CorrectWordDisplay(
                              correctWord: controller.correctWord),
                        ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(size.height * 0.015),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Letter7Part1(
                                        wordLength: widget.wordLength),
                                  ));
                              controller.resetGame();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.025,
                                  horizontal: size.width * 0.1),
                              textStyle: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            ),
                            child: Text(
                              controller.gameWon
                                  ? "Tebrikler! ₺${controller.totalEarnings + controller.amount}"
                                  : "Tekrar Dene! ₺${controller.totalEarnings + controller.amount}",
                            ),
                          ),
                        ),
                      ),
                    ],
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

  AppBar _buildAppBar(Size size) {
    return AppBar(
      backgroundColor: const Color(0xff000D31),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _LogoText(),
          _CurrencyContainer(size),
        ],
      ),
    );
  }
}

class _LogoText extends StatelessWidget {
  const _LogoText();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'LINGO',
            style: TextStyle(
              color: const Color(0xFFFBF9F7),
              fontSize: size.width * 0.1, // 📌 Dinamik font boyutu
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'G',
            style: TextStyle(
              color: const Color(0xFF9F2927),
              fontSize: size.width * 0.1, // 📌 Dinamik font boyutu
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class CorrectWordDisplay extends StatelessWidget {
  final String correctWord;

  const CorrectWordDisplay({super.key, required this.correctWord});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(correctWord.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.009),
            child: Container(
              width: size.width * 0.095, // 📌 Dinamik genişlik
              height: size.width * 0.115, // 📌 Dinamik yükseklik
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF207A2F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                correctWord[index].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.07, // 📌 Dinamik font
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CurrencyContainer extends StatelessWidget {
  final Size size;
  const _CurrencyContainer(this.size);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);

    return Container(
      width: size.width * 0.4,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: const Color(0xFF207A2F),
        border: Border.all(width: 2.5, color: Colors.white),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '₺${controller.amount}',
          key: ValueKey(controller.amount),
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.08, // 📌 Dinamik font
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
