import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:lingogame/constants/answer_stages.dart';
import 'package:lingogame/constants/keyboardKeyState.dart';
import 'package:lingogame/constants/keys_map.dart';
import 'package:lingogame/models/tile_model.dart';
import 'package:lingogame/constants/words.dart'; // Kelime listesi buradadır.

class Controller extends ChangeNotifier {
  // Oyun durum değişkenleri
  bool checkLine = false;
  bool backOrEnterTapped = false;
  bool gameWon = false;
  bool gameCompleted = false;
  bool notEnoughLetters = false;
  int amount = 2000;
  int totalEarnings = 0;

  // keysMap harflerin durumlarını tutan bir map olmalı
  Map<String, KeyboardKeyState> keysMap = {};

  // Klavye durumlarını başlat
  void initKeyStates() {
    keysMap = {}; // keysMap'i boş olarak başlatıyoruz
    for (var key in keysMap.keys) {
      keysMap[key] = KeyboardKeyState.knotAnswered; // Başlangıç durumu
    }
  }

  // Harf durumunu almak için
  KeyboardKeyState getKeyState(String key) {
    return keysMap[key] ?? KeyboardKeyState.knotAnswered;
  }

  // Kelime ve kutu durumları
  String correctWord = "";
  int currentTile = 0;
  int currentRow = 0;
  List<TileModel> tilesEntered = [];

  // Zaman yönetimi
  int gameTime = 10;
  Timer? _timer;

  // Doğru kelimeyi ayarla
  void setCorrectWord({required String word}) {
    correctWord = word.toUpperCase();
    _resetTimer();
    if (tilesEntered.isEmpty) {
      // _firstLetter();
    }
  }

  // Harf girişlerini işle
  void setKeyTapped({required String value}) {
    if (gameCompleted == true) {
      _stopTimer();
      return;
    }

    backOrEnterTapped = value == 'ENTER' || value == 'BACK';
    notEnoughLetters = false;

    if (gameTime > 0) {
      if (value == 'ENTER') {
        _handleEnter();
      } else if (value == 'BACK') {
        _handleBackspace();
      } else {
        _handleLetterInput(value);
      }
    } else {
      _endGame(false);
      _stopTimer(); // Zamanlayıcıyı durdur
      amount = 0;
    }
    notifyListeners();
  }

  void _handleEnter() {
    if (currentTile == 5 * (currentRow + 1)) {
      backOrEnterTapped = true;
      checkLine = true; // Trigger animation for next round
      _processGuess();
      _resetTimer(); // Timer'ı sıfırlayıp 10'dan başlat
    } else {
      notEnoughLetters = true;
    }
  }

  void _handleBackspace() {
    backOrEnterTapped = true;
    if (currentTile > 5 * currentRow) {
      currentTile--;
      tilesEntered.removeLast();
    }
  }

  void _handleLetterInput(String value) {
    if (currentTile < 5 * (currentRow + 1)) {
      tilesEntered.add(TileModel(
        letter: value.toUpperCase(),
        answerStage: AnswerStage.notAnswered,
      ));
      currentTile++;
    }
  }

  // void _firstLetter() {
  //   İlk harfi otomatik doldur, ancak yalnızca ilk satırda olsun
  //   if (currentRow == 0) {
  //     tilesEntered.add(TileModel(
  //       letter: correctWord[0],
  //       answerStage: AnswerStage.correct,
  //     ));
  //     currentTile++;
  //     _updateKeyColor(correctWord[0], KeyboardKeyState.kcorrect);

  //     İlk harf doğruysa animasyonu tetikle
  //     checkLine = true; // Animasyon tetikleniyor
  //     notifyListeners(); // Animasyonun hemen görünmesi için notifyListeners()
  //   }
  // }

  void _processGuess() {
    final guessedWord = _getCurrentRowWord();
    final remainingCorrect = List.of(correctWord.characters);

    // İlk satırda özel kontrol
    if (currentRow == 0) {
      if (guessedWord[0] != correctWord[0]) {
        _markAllIncorrect(); // İlk harf yanlışsa, tüm harfler kırmızı olur
        _endGame(false); // Oyunu sonlandır
        _stopTimer();
        amount = 0;
      } else if (!words.contains(guessedWord)) {
        _markAllIncorrect(); // Kelime listede yoksa, tüm harfler kırmızı olur
        _endGame(false); // Oyunu sonlandır
        _stopTimer();
        amount = 0;
      } else if (guessedWord == correctWord) {
        _markAllCorrect(); // Tüm harfler doğru ise, yeşil olur
        _endGame(true); // Kazanılırsa oyun sonlanır
        _stopTimer();
      } else {
        _checkLetters(
            guessedWord, remainingCorrect); // Diğer harfler için normal kontrol
        amount -= 400;
        currentRow++;
        if (currentRow == 6) {
          _endGame(false); // 6. satırda hâlâ kazanılmadıysa, oyun sonlanır
          _stopTimer();
        }
      }
    } else {
      // Diğer satırlarda normal işlem
      if (guessedWord == correctWord) {
        _markAllCorrect();
        _endGame(true); // Kazanılırsa oyun sonlanır
        _stopTimer();
      } else {
        _checkLetters(guessedWord, remainingCorrect);
        amount -= 400;
        currentRow++;
        if (currentRow == 6) {
          _endGame(false); // 6. satırda hâlâ kazanılmadıysa, oyun sonlanır
          _stopTimer();
          amount = 0;
        }
      }
    }

    // Animasyonu tetikle
    checkLine = true; // Şu anki satır için animasyonu başlat
    notifyListeners(); // Animasyonu tetiklemek

    // Her satır için animasyon bittiğinde bir sonraki satıra geçilir
    if (checkLine) {
      _handleNextRow();
    }
  }

  void _handleNextRow() {
    // Satır tamamlandığında bir sonraki satıra geçilir, ancak önceki satır tekrar animasyona girmez.
    if (currentRow < 6) {
      checkLine = false; // Animasyon tamamlandı
      notifyListeners(); // Animasyon tamamlandığını bildir
    }
  }

  String _getCurrentRowWord() {
    return tilesEntered
        .sublist(currentRow * 5, (currentRow * 5) + 5)
        .map((tile) => tile.letter)
        .join();
  }

  void _markAllCorrect() {
    for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
      tilesEntered[i].answerStage = AnswerStage.correct;
      _updateKeyColor(tilesEntered[i].letter, KeyboardKeyState.kcorrect);
      checkLine = true; // Trigger animation for next round
    }
    gameWon = true;
    _stopTimer();
  }

  void _markAllIncorrect() {
    for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
      tilesEntered[i].answerStage = AnswerStage.incorrect;
      _updateKeyColor(tilesEntered[i].letter, KeyboardKeyState.kincorrect);
      checkLine = true; // Trigger animation for next round
      _stopTimer();
    }
  }

  void _checkLetters(String guessedWord, List<String> remainingCorrect) {
    // 1. Adım: Doğru pozisyon ve harfleri işaretle
    for (int i = 0; i < 5; i++) {
      final tileIndex = i + currentRow * 5;

      // Harf doğru pozisyonda ise yeşil yapılır
      if (guessedWord[i] == correctWord[i]) {
        tilesEntered[tileIndex].answerStage = AnswerStage.correct;
        remainingCorrect.remove(guessedWord[i]);
        _updateKeyColor(guessedWord[i],
            KeyboardKeyState.kcorrect); // Her harfe animasyon ekle
      } else {
        // Harf doğru kelimede yoksa gri yapılır
        tilesEntered[tileIndex].answerStage = AnswerStage.incorrect;
        _updateKeyColor(guessedWord[i],
            KeyboardKeyState.kincorrect); // Her harfe animasyon ekle
      }
    }

    // 2. Adım: Yanlış pozisyon ve doğru harfleri işaretle
    for (int i = 0; i < 5; i++) {
      final tileIndex = i + currentRow * 5;

      // Harf doğru kelimede var ama yanlış pozisyondaysa sarı yapılır
      if (remainingCorrect.contains(guessedWord[i]) &&
          guessedWord[i] != correctWord[i]) {
        tilesEntered[tileIndex].answerStage = AnswerStage.contains;
        remainingCorrect.remove(guessedWord[i]);
        _updateKeyColor(guessedWord[i],
            KeyboardKeyState.kcontains); // Her harfe animasyon ekle
      }
    }

    checkLine = true; // Trigger animation for the current row
  }

  void _updateKeyColor(String key, KeyboardKeyState newStage) {
    if (keysMap[key] == null ||
        keysMap[key]! == KeyboardKeyState.knotAnswered) {
      keysMap[key] = newStage;
    } else if (newStage == KeyboardKeyState.kcorrect) {
      // Doğru harf her zaman yeşil olmalı
      keysMap[key] = KeyboardKeyState.kcorrect;
    } else if (newStage == KeyboardKeyState.kcontains &&
        keysMap[key]! != KeyboardKeyState.kcorrect) {
      // Yanlış pozisyondaki harf sarı olmalı (ancak zaten yeşil değilse)
      keysMap[key] = KeyboardKeyState.kcontains;
    } else if (newStage == KeyboardKeyState.kincorrect &&
        keysMap[key]! == KeyboardKeyState.knotAnswered) {
      // Yanlış harf yalnızca gri yapılmalı
      keysMap[key] = KeyboardKeyState.kincorrect;
    }
    notifyListeners(); // UI güncellemeyi bildir
  }

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    if (gameCompleted == false) {
      // Yeni bir timer başlatıyoruz
      gameTime = 10;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (gameTime > 0) {
          gameTime--;
        } else {
          _endGame(false); // Süre bittiğinde oyunu sonlandır
        }
        notifyListeners();
      });
    }
  }

  void _endGame(bool win) {
    gameCompleted = true;
    gameWon = win;
    _stopTimer(); // Zamanlayıcıyı durduruyoruz

    if (!win) {
      // Eğer oyun kaybedildiyse amount'u sıfırlıyoruz
      amount = 0;
    }

    notifyListeners(); // Durum güncellemesi
  }

  void _stopTimer() {
    _timer!.cancel(); // Zamanlayıcıyı durdur
  }

  void resetKeyboard() {
    // keysMap'i varsayılan duruma döndür
    keysMap.forEach((key, value) {
      keysMap[key] = KeyboardKeyState.knotAnswered;
    });
    notifyListeners(); // UI güncellemeyi bildir
  }

  void resetGame() {
    if (gameCompleted == true && gameWon == true) {
      totalEarnings += amount;
    }

    gameWon = false;
    gameCompleted = false;
    currentRow = 0;
    currentTile = 0;
    tilesEntered.clear();
    notEnoughLetters = false;
    checkLine = false;
    backOrEnterTapped = false;
    amount = 2000;
    // _firstLetter();
    resetKeyboard();
    _resetTimer();
    notifyListeners();
  }
}
