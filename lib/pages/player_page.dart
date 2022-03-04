import 'dart:async';
import 'dart:convert';
import 'package:ayat/utils/Times.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

class PlayerPage extends StatefulWidget {
  int? start;
  int? end;
  PlayerPage({Key? key, this.start, this.end}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer _player;
  late AudioPlayer _clip;
  late Duration? _duration;
  late int _start;
  late int _end;
  late int _currentVerse;

// TODO: get times from API.
  final _positions = Times().positons;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _start = widget.start ?? 0;
    _currentVerse = _start;
    _end = widget.end ?? _positions.length - 1;
    _player = AudioPlayer();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    int _tick = 100;
    _duration = await _player.setUrl('https://server7.mp3quran.net/s_gmd/057.mp3');
    _duration = await _player.load();

    _player.seek(Duration(milliseconds: _positions[_start - 1]));
    Timer.periodic(Duration(milliseconds: _tick), (Timer t) async {
      if (_player.playing) {
        final position = _player.position;

        if (position.inMilliseconds >= _positions[_currentVerse]) {
          setState(() {
            _currentVerse++;
          });
        }

        if (position.inMilliseconds > _positions[_end]) {
          await _player.seek(Duration(milliseconds: _positions[_start - 1]));
          setState(() {
            _currentVerse = _start;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //timer for updating the position

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: QuranText(
                    start: _start,
                    end: _end,
                    current: _currentVerse,
                  ),
                ),
              ),
            ),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipButton(
                    onIncrement: incrementStart,
                    onDecrement: decrementStart,
                    aya: _start,
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _player.playing ? _player.pause() : _player.play();
                    }),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                      size: 48,
                    ),
                  ),
                  ClipButton(
                    onIncrement: incrementEnd,
                    onDecrement: decrementEnd,
                    aya: _end,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void incrementStart() async {
    if (_start >= _positions.length - 1) return;
    setState(() {
      if (_start >= _end) {
        _end = _end + 1;
      }
      _start = _start + 1;
      _currentVerse = _start;
    });
    await _player.seek(Duration(milliseconds: _positions[_start - 1]));
  }

  void decrementStart() async {
    if (_start <= 1) return;
    setState(() {
      _start = _start - 1;
      _currentVerse = _start;
    });
    await _player.seek(Duration(milliseconds: _positions[_start - 1]));
  }

  void incrementEnd() async {
    if (_end >= _positions.length - 1) return;
    setState(() {
      _end = _end + 1;
    });
  }

  void decrementEnd() async {
    if (_end <= 1) return;
    setState(() {
      _end = _end - 1;
      if (_end <= _start) {
        _start = _end;
      }
    });
  }
}

class ClipButton extends StatelessWidget {
  final Function onIncrement;
  final Function onDecrement;
  final int aya;

  const ClipButton({
    Key? key,
    required this.onIncrement,
    required this.onDecrement,
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
            onPressed: () {},
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

class QuranText extends StatelessWidget {
  final int start;
  final int end;
  final surahNumber = 57;
  final int current;

  QuranText({
    Key? key,
    required this.start,
    required this.end,
    required this.current,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.start,
        textScaleFactor: 1,
        strutStyle: StrutStyle(
          // height: 2,
          leading: 2,
        ),
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'meQuran',
            fontSize: 16,
          ),
          children: List.generate(end - start + 1, (i) {
            String verse = quran.getVerse(surahNumber, start + i);
            return TextSpan(
              text: '$verse   (${start + i})   ',
              style: TextStyle(
                color: current == start + i ? Colors.blue : null,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('$verse - ${start + i}');
                },
            );
          }),
        ),
      ),
    );
  }
}
