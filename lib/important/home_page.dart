import 'package:flutter/material.dart';
import 'package:lingogame/Levels/letter4Part1.dart';
import 'package:lingogame/Levels/letter5Part1.dart'; // 5 Harfli Kelimeler

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
            const _Header(), // Logo ve Karşılama Mesajı
            const SizedBox(height: 40),
            _buildButton(context, '4 Harfli Kelimeler', const Color(0xFF0801FF),
                const Letter4Part1()),
            _buildButton(context, '5 Harfli Kelimeler', const Color(0xFF207A2F),
                const Letter5Part1()),
            _buildButton(context, '6 Harfli Kelimeler', const Color(0xFFFFB200),
                const Letter5Part1()),
            _buildButton(context, '7 Harfli Kelimeler', const Color(0xFF9F2927),
                const Letter5Part1()),
            _buildButton(
              context,
              'LINGO\'ya Başla',
              Colors.white,
              const Letter5Part1(),
              textColor: const Color(0xFF000D31),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, Widget page,
      {Color textColor = Colors.white}) {
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => page));
          },
          child: Text(
            text,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: textColor),
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
