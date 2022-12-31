import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:quran/quran.dart' as quran;

class QuranText extends StatelessWidget {
  final int start;
  final int end;
  final int surahNumber;
  final int current;
  final Function tap;
  final int? isolatedVers;
  final bool isSelecting;

  QuranText({
    Key? key,
    required this.surahNumber,
    required this.start,
    required this.end,
    required this.current,
    required this.tap,
    required this.isSelecting,
    this.isolatedVers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _listLength = end - start + 1;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        textScaleFactor: 1,
        textWidthBasis: TextWidthBasis.parent,
        strutStyle: StrutStyle(
          leading: 2,
        ),
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'meQuran',
            fontSize: 16,
          ),
          children: List.generate(_listLength, (i) {
            String verse = quran.getVerse(surahNumber, start + i);
            String endSymbol = quran.getVerseEndSymbol(start + i);
            return TextSpan(
              text: '$verse   (${start + i})   ',
              // text: '$verse   $endSymbol   ',
              style: isolatedVers == null
                  ? TextStyle(color: current == start + i ? Colors.blue : Colors.black)
                  : TextStyle(color: current == start + i ? Colors.blue : Colors.black12),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  tap(start + i);
                },
            );
          }),
        ),
      ),
    );
  }
}
