import 'package:flutter/material.dart';

class ClipButton extends StatelessWidget {
  final Function onIncrement;
  final Function onDecrement;
  final Function onSelect;
  final int aya;

  const ClipButton({
    Key? key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSelect,
    required this.aya,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Icon(Icons.keyboard_arrow_up_rounded),
            onPressed: () => onIncrement(),
          ),
          TextButton(
            onPressed: () => onSelect(),
            child: Text(
              '$aya',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          TextButton(
            child: Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: () => onDecrement(),
          ),
        ],
      ),
    );
  }
}
