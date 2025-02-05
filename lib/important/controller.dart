import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:lingogame/constants/answer_stages.dart';
import 'package:lingogame/constants/keyboardKeyState.dart';
import 'package:lingogame/models/tile_model.dart';
import 'package:lingogame/constants/words.dart'; // Kelime listesi buradadır.

class Controller extends ChangeNotifier {
  // Oyun durum değişkenleri
  bool checkLine = false;
  bool backOrEnterTapped = false;
  bool gameWon = false;
  bool gameCompleted = false;
  bool notEnoughLetters = true;
  int amount = 2000;
  int totalEarnings = 0;

  int wordLength; // Seçilen kelime uzunluğu
  List<String> wordsDictionary = []; // ✅ Global kelime listesi

  Controller({this.wordLength = 5}) {
    setWordLength(wordLength); // ✅ Başlangıçta kelime listesini güncelle
  }

  String correctWord = "";

  void setWordLength(int length) {
    wordLength = length;

    if (length == 4) {
      wordsDictionary = words4;
    } else if (length == 5) {
      wordsDictionary = words5;
    } else if (length == 6) {
      wordsDictionary = words6;
    } else if (length == 7) {
      wordsDictionary = words7;
    } else {
      wordsDictionary = words4;
    }

    resetGame(); // ✅ Yeni uzunluk seçilince oyunu sıfırla
    _selectRandomWord();
    notifyListeners();
  }

  void _selectRandomWord() {
    if (wordsDictionary.isNotEmpty) {
      correctWord = wordsDictionary[Random().nextInt(wordsDictionary.length)]
          .toUpperCase();
    } else {
      correctWord =
          "ERROR"; // Eğer kelime yoksa hata yerine varsayılan değer koy
    }

    print("Yeni kelime: $correctWord");
  }

  // keysMap harflerin durumlarını tutan bir map olmal
  Map<String, KeyboardKeyState> keysMap = {};
  Set<String> previousGuesses = {}; // Daha önce girilen kelimeleri tutar

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
  // String correctWord = "";
  int currentTile = 0;
  int currentRow = 0;
  List<TileModel> tilesEntered = [];

  // Zaman yönetimi
  int gameTime = 10;
  Timer? _timer;

  // Doğru kelimeyi ayarla
  void setCorrectWord({required String word}) {
    correctWord = word.toUpperCase();
    print("Correct word is: $correctWord");
    _resetTimer();

    if (currentTile == 0 && currentRow == 0) {
      _firstLetter();
    }

    if (currentRow >= 4) {
      _processGuess();
    }
    notifyListeners();
  }

  // Harf girişlerini işle
  void setKeyTapped({required String value}) {
    if (gameCompleted == true) {
      _stopTimer();
      return;
    }

    backOrEnterTapped = value == 'ENTER' || value == 'BACK';

    if (gameTime > 0 && currentRow < wordLength && !gameCompleted) {
      if (currentTile == 0 && currentRow == 0) {
        _firstLetter();
      } else if (value == 'ENTER' && notEnoughLetters == false) {
        _handleEnter();
        checkLine = true; // Animasyonu tetiklemek için true yapıyoruz
        notifyListeners(); // UI'yi güncelliyoruz
      } else if (value == 'BACK') {
        _handleBackspace();
        checkLine = false;
      } else {
        _handleLetterInput(value);
      }
    } else {
      _endGame(false);
      amount = 0;
    }
    notifyListeners();
  }

  void _handleEnter() {
    // Eğer tam 5 harf girilmemişse ENTER çalışmasın
    if ((currentTile - (currentRow * wordLength)) < wordLength) {
      notEnoughLetters = true;
      notifyListeners();
      return;
    } else {
      notEnoughLetters = false;
      // checkLine = true; // Animasyonu başlat
      _processGuess();

      _stopTimer();
      Future.delayed(const Duration(seconds: 1), () {
        if (!gameCompleted) {
          _resetTimer();
          _stopTimer();
          _resetTimer();
        }
      });
    }
  }

  void _handleBackspace() {
    if (currentTile > (wordLength * currentRow)) {
      backOrEnterTapped = true; // Sadece geri silme için
      currentTile--;
      notEnoughLetters =
          currentTile < (wordLength * (currentRow + 1)); // Doğru kontrol

      if (tilesEntered.isNotEmpty) {
        tilesEntered.removeLast();
      }
      notifyListeners();
    }
  }

  void _handleLetterInput(String value) {
    // Eğer "ENTER" veya "BACK" gelirse harf olarak eklenmesin
    if (value == "ENTER" || value == "BACK") return;

    // Eğer kutular dolu değilse harfi ekleyelim
    if (currentTile < wordLength * (currentRow + 1)) {
      tilesEntered.add(TileModel(
        letter: value.toUpperCase(),
        answerStage: AnswerStage.notAnswered,
      ));
      currentTile++;

      // Eğer satır tamamlandıysa "notEnoughLetters" sıfırlanır
      notEnoughLetters = (currentTile % wordLength) != 0;
      notifyListeners();
    }
  }

  void _firstLetter() {
    // İlk harfi otomatik doldur, ancak yalnızca ilk satırda olsun
    if (currentRow == 0) {
      tilesEntered.add(TileModel(
        letter: correctWord[0],
        answerStage: AnswerStage.correct,
      ));
      currentTile++;
      _updateKeyColor(correctWord[0], KeyboardKeyState.kcorrect);
    }
  }

  void _processGuess() {
    final guessedWord = _getCurrentRowWord();

    // Eğer bu kelime daha önce girilmişse oyunu bitir
    if (previousGuesses.contains(guessedWord)) {
      _endGame(false);
      notifyListeners();
      return;
    }
    previousGuesses.add(guessedWord);

    final remainingCorrect = List.of(correctWord.characters);

    if (guessedWord[0] != correctWord[0]) {
      _endGame(false); // Oyunu sonlandır
      amount = 0;
    } else if (!wordsDictionary.contains(guessedWord)) {
      _endGame(false); // Oyunu sonlandır
      amount = 0;
    } else if (guessedWord == correctWord) {
      _endGame(true); // Kazanılırsa oyun sonlanır
    } else {
      _checkLetters(
          guessedWord, remainingCorrect); // Diğer harfler için normal kontrol
      amount -= 400;

      if (currentRow < wordLength - 1) {
        currentRow++;
      } else if (currentRow == wordLength - 1) {
        _processGuess();
      }
      // Animasyonu tetikle

      checkLine = true; // Şu anki satır için animasyonu başlat
      notifyListeners(); // Animasyonu tetiklemek
    }

    // // Animasyonu tetikle
    // checkLine = true; // Şu anki satır için animasyonu başlat
    // notifyListeners(); // Animasyonu tetiklemek
    _handleNextRow();
  }

  void _handleNextRow() {
    // Satır tamamlandığında bir sonraki satıra geçilir, ancak önceki satır tekrar animasyona girmez.
    if (currentRow < wordLength) {
      checkLine = false; // Animasyon tamamlandı
      notifyListeners(); // Animasyon tamamlandığını bildir
    }
  }

  String _getCurrentRowWord() {
    return tilesEntered
        .sublist(
            currentRow * wordLength, (currentRow * wordLength) + wordLength)
        .map((tile) => tile.letter)
        .join();
  }

  void _markAllCorrect() {
    for (int i = currentRow * wordLength;
        i < (currentRow * wordLength) + wordLength;
        i++) {
      tilesEntered[i].answerStage = AnswerStage.correct;
      _updateKeyColor(tilesEntered[i].letter, KeyboardKeyState.kcorrect);
      checkLine = true; // Trigger animation for next round
    }
    gameWon = true;
    gameCompleted = true;
    _stopTimer();
    notifyListeners();
  }

  void _markAllIncorrect() {
    for (int i = currentRow * wordLength;
        i < (currentRow * wordLength) + wordLength;
        i++) {
      tilesEntered[i].answerStage = AnswerStage.falseRed;
      _updateKeyColor(tilesEntered[i].letter, KeyboardKeyState.kincorrect);
      checkLine = true; // Trigger animation for next round
    }
    gameWon = false;
    gameCompleted = true;
    _stopTimer();
    notifyListeners();
  }

  void _checkLetters(String guessedWord, List<String> remainingCorrect) {
    // 1. Adım: Doğru pozisyon ve harfleri işaretle
    for (int i = 0; i < wordLength; i++) {
      final tileIndex = i + currentRow * wordLength;

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
    for (int i = 0; i < wordLength; i++) {
      final tileIndex = i + currentRow * wordLength;

      // Harf doğru kelimede var ama yanlış pozisyondaysa sarı yapılır
      if (remainingCorrect.contains(guessedWord[i]) &&
          guessedWord[i] != correctWord[i]) {
        tilesEntered[tileIndex].answerStage = AnswerStage.contains;
        remainingCorrect.remove(guessedWord[i]);
        _updateKeyColor(guessedWord[i],
            KeyboardKeyState.kcontains); // Her harfe animasyon ekle
      }
    }

    // checkLine = true; // Trigger animation for the current row
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

    if (!gameCompleted) {
      gameTime = 10;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (gameTime > 0) {
          gameTime--;
        } else {
          _endGame(false);
        }
        notifyListeners();
      });
    }
  }

  void _endGame(bool win) {
    gameCompleted = true;
    checkLine = true; // Animasyonu tetikle
    if (win) {
      _markAllCorrect();
    } else if (!win) {
      amount = 0;
      _markAllIncorrect();
    }
    _stopTimer();
    notifyListeners(); // Tüm değişikliklerden sonra bir kez çağrılır
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
    notEnoughLetters = true;
    checkLine = false;
    backOrEnterTapped = false;
    amount = 2000;
    previousGuesses.clear();
    // _firstLetter();
    resetKeyboard();
    _resetTimer();
    notifyListeners();
  }
}
