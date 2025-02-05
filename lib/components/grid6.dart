import 'package:flutter/material.dart';
import 'package:lingogame/animations/bounce.dart';
import 'package:lingogame/animations/dance.dart';
import 'package:lingogame/components/tile.dart';
import 'package:lingogame/important/controller.dart';
import 'package:provider/provider.dart';

class Grid6 extends StatelessWidget {
  const Grid6({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(builder: (_, notifier, __) {
      double screenWidth =
          MediaQuery.of(context).size.width; // 📱 Ekran genişliği (dp)
      double screenHeight =
          MediaQuery.of(context).size.height; // 📱 Ekran yüksekliği (dp)

      int wordLength =
          notifier.wordLength; // ✅ Seçili kelime uzunluğu (4,5,6,7)
      double spacing =
          screenWidth * 0.015; // 📏 Boşlukları dinamik yap (1.5% genişlik)
      double gridPadding =
          screenWidth * 0.007; // 📏 Kenar boşluğu (2% genişlik)

      // 🟢 Kutu boyutunu **ekran genişliğinin % ile hesapla**
      double tileSize = (screenWidth) / wordLength;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: gridPadding),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: wordLength * 5,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wordLength, // ✅ Dinamik sütun sayısı
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.95, // ✅ Kare oranını koru
          ),
          itemBuilder: (context, index) {
            return Consumer<Controller>(
              builder: (_, notifier, __) {
                bool animate = false;
                bool animateDance = false;
                int danceDelay = 1600;

                if (index == (notifier.currentTile - 1) &&
                    !notifier.notEnoughLetters) {
                  animate = true;
                }

                if (notifier.gameWon) {
                  for (int i = notifier.tilesEntered.length - wordLength;
                      i < notifier.tilesEntered.length;
                      i++) {
                    if (index == i) {
                      animateDance = true;
                      danceDelay +=
                          150 * (i - ((notifier.currentRow - 1) * wordLength));
                    }
                  }
                }

                return SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: Dance(
                    delay: danceDelay,
                    animate: animateDance,
                    child: Bounce(
                      animate: animate,
                      child: Tile(index: index),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }
}
