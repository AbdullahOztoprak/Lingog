import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingogame/Levels/letter5Part1.dart';
import 'package:lingogame/components/grid.dart';
import 'package:lingogame/components/keyboard_row.dart';
import 'package:lingogame/components/timer.dart';
import 'package:lingogame/constants/words.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _word;

  @override
  void initState() {
    super.initState();
    final r = Random().nextInt(words.length);
    _word = words[r];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<Controller>(context, listen: false);
      controller.resetGame(); // Önce oyunu sıfırla
      controller.setCorrectWord(word: _word); // Sonra yeni kelimeyi ayarla
    });
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
              padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
              child: const Grid(),
            ),
          ),
          Expanded(
            flex: 5,
            child: controller.gameCompleted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Doğru kelime kutuları
                      if (!controller.gameWon)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: CorrectWordDisplay(
                              correctWord: controller.correctWord),
                        ),

                      // "Tekrar Dene" Butonu (Flexible ile taşma önleniyor)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Letter5Part1()),
                              );

                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                controller.resetGame();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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

class CorrectWordDisplay extends StatelessWidget {
  final String correctWord;

  const CorrectWordDisplay({super.key, required this.correctWord});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 3), // Kutular arası boşluk
            child: Container(
              width: 52, // Kutuların genişliği
              height: 52, // Kutuların yüksekliği
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(
                    0xFF207A2F), // Doğru kelime olduğu için yeşil kutular
                borderRadius: BorderRadius.circular(4),
                // border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                correctWord[index].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32, // Tile widget'ına uygun font büyüklüğü
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '₺${controller.amount}',
          key: ValueKey(controller.amount), // Değer değiştikçe animasyon uygula
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
