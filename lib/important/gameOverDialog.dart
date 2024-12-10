import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String message;

  const GameOverDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message, textAlign: TextAlign.center),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Oyunu yeniden başlatıyoruz
            Navigator.of(context).pop();
            // Restart işlemi burada yapılabilir
          },
          child: const Text('Play Again'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Quit'),
        ),
      ],
    );
  }
}
