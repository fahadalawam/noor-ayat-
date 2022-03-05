import 'dart:async';
import 'package:ayat/utils/timing.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

class PlayerPage extends StatefulWidget {
  int start;
  int end;
  int surahNumber;
  PlayerPage({
    Key? key,
    required this.surahNumber,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer _player;
  late AudioPlayer _clip;
  late Duration? _duration;
  late int _srahNumber;
  late int _start;
  late int _end;
  late int _currentVerse;
  late ScrollController _controller;
// TODO: get times from API.
  final List<int> _positions = Timing(surahId: 2).positons;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _srahNumber = widget.surahNumber;
    _start = widget.start;
    _currentVerse = _start;
    _end = widget.end;
    _player = AudioPlayer();

    _controller = ScrollController();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    int _tick = 100;
    final String _s = _srahNumber.toString().padLeft(3, '0');
    _duration = await _player.setUrl('https://download.quranicaudio.com/qdc/khalil_al_husary/murattal/$_srahNumber.mp3');
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

  void jumpTo(int verse) async {
    setState(() {
      _currentVerse = verse;
    });
    await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
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
                    surahNumber: _srahNumber,
                    start: _start,
                    end: _end,
                    current: _currentVerse,
                    jumpTo: jumpTo,
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
      // _currentVerse = _start;
    });
    if (_start <= _currentVerse) return;
    _currentVerse = _start;
    await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
  }

  void decrementStart() async {
    if (_start <= 1) return;
    setState(() {
      _start = _start - 1;
      // _currentVerse = _start;
    });
    // await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
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
      if (_end <= _start) _start = _end;
      if (_end < _currentVerse) {
        _currentVerse = _start;
        _player.seek(Duration(milliseconds: _positions[_start - 1]));
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
  final surahNumber;
  final int current;
  final Function jumpTo;

  QuranText({
    Key? key,
    required this.surahNumber,
    required this.start,
    required this.end,
    required this.current,
    required this.jumpTo,
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
                  jumpTo(start + i);
                },
            );
          }),
        ),
      ),
    );
  }
}
