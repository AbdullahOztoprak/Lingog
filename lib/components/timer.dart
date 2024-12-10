import 'package:flutter/material.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart'; // Make sure to import provider

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, controller, child) {
        return Column(
          children: [
            SizedBox(
              width: 120,
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 50,
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFFB200),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEBEAFF),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 50,
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF9F2927),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 0,
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF0801FF),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Container(
                      width: 90,
                      height: 70,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF207A2F),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 3, color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${controller.gameTime}', // Timer'ı göstermek için gameTime
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
