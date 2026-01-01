import 'package:flutter/material.dart';

extension DurationFormatter on Duration {
  String toHMS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(inHours)}:'
           '${twoDigits(inMinutes.remainder(60))}:'
           '${twoDigits(inSeconds.remainder(60))}';
  }
}


class SpinButton extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const SpinButton({
    required this.value,
    required this.onIncrement,
    this.onDecrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        Text('$value'),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
