import 'package:flutter/material.dart';
import 'package:lingogame/Levels/letter4Part1.dart';
import 'package:lingogame/Levels/letter5Part1.dart';
import 'package:lingogame/Levels/letter6Part1.dart';
import 'package:lingogame/Levels/letter7Part1.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000D31),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _Header(),
            const SizedBox(height: 40),
            _buildButton(
                context, '4 Harfli Kelimeler', const Color(0xFF0801FF), 4),
            _buildButton(
                context, '5 Harfli Kelimeler', const Color(0xFF207A2F), 5),
            _buildButton(
                context, '6 Harfli Kelimeler', const Color(0xFFFFB200), 6),
            _buildButton(
                context, '7 Harfli Kelimeler', const Color(0xFF9F2927), 7),
            _buildButton(context, 'Lingoya başlayın', Colors.cyan, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, int length) {
    final controller = Provider.of<Controller>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 37),
      child: SizedBox(
        width: 357,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            controller.setWordLength(length); // ✅ Seçilen uzunluğu kaydet

            // ✅ Seçilen uzunluğa göre doğru sayfaya yönlendir
            Widget nextPage;
            if (length == 4) {
              nextPage = Letter4Part1(wordLength: length);
            } else if (length == 5) {
              nextPage = Letter5Part1(wordLength: length);
            } else if (length == 6) {
              nextPage = Letter6Part1(wordLength: length);
            } else if (length == 7) {
              nextPage = Letter7Part1(wordLength: length);
            } else {
              nextPage = Letter4Part1(wordLength: length);
            }

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => nextPage));
          },
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'LINGO',
                style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                    color: Colors.white),
              ),
              TextSpan(
                text: 'G',
                style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                    color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Hoşgeldin',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 20, fontFamily: 'Roboto', color: Colors.grey),
        ),
        SizedBox(height: 10),
        Text(
          'Abdullah Baba',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
              color: Colors.white),
        ),
      ],
    );
  }
}
