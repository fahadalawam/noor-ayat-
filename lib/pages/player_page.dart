import 'dart:async';
import 'package:ayat/models/clip.dart';
import 'package:ayat/providers/prevs.dart';
import 'package:ayat/utils/timing.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:wakelock/wakelock.dart';

import 'package:provider/provider.dart';

import '../widgets/quran_text.dart';
import '../widgets/clip_button.dart';

// import 'package:shared_preferences/shared_preferences.dart';

enum SelectionMode { start, end }

class PlayerPage extends StatefulWidget {
  static const PAGE_NAME = 'player-page/';

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
  late int _surahNumber;
  late int _start;
  late int _end;
  late int _tempStart;
  late int _tempEnd;
  late int _currentVerse;
  late ScrollController _controller;
// TODO: get times from API.
  late List<int> _positions;
  bool _isLoading = true;

  late Timer _timer;

  int? isolatedVers;
  SelectionMode? _selectionMode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Wakelock.toggle(enable: true);
    _surahNumber = widget.surahNumber;
    _start = widget.start;
    _currentVerse = _start;
    _end = widget.end;
    _player = AudioPlayer();

    _controller = ScrollController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('dispos...');
    Wakelock.toggle(enable: false);
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    int _tick = 50;
    //saud_ash-shuraym 10
    //abu_bakr_shatri 4
    //https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/067.mp3
    String s = _surahNumber.toString().padLeft(3, '0');

    _duration = await _player.setUrl(
        'https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/$s.mp3');
    _duration = await _player.load();

    await Timing(surahId: _surahNumber).fetchTiming().then((value) {
      setState(() {
        _positions = value;
        _isLoading = false;
        _player.seek(Duration(milliseconds: _positions[_start - 1]));
        _player.play();
      });
    });

    Provider.of<Prevs>(context, listen: false).saveLatest(Clip(
      surahNumber: _surahNumber,
      start: _start,
      end: _end,
    ));

    _timer = Timer.periodic(Duration(milliseconds: _tick), (Timer t) async {
      // print(_positions);
      if (_player.playing) {
        final position = _player.position;

        if (isolatedVers != null) {
          if (position.inMilliseconds > _positions[isolatedVers!]) {
            await _player
                .seek(Duration(milliseconds: _positions[isolatedVers! - 1]));
          }
          return;
        }

        if (position.inMilliseconds >= _positions[_currentVerse]) {
          setState(() {
            _currentVerse++;
          });
        }

        if (position.inMilliseconds > _positions[_end]) {
          _player.seek(Duration(milliseconds: _positions[_start - 1]));
          setState(() {
            _currentVerse = _start;
            _player.pause();
            _isLoading = true;
          });
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _isLoading = false;
            _player.play();
          });
        }
      }
    });
  }

  void onSelect(int verse) async {
    if (_selectionMode != null) {
      if (_selectionMode == SelectionMode.start) {
        if (verse > _tempEnd) _tempEnd = verse;
        setState(() {
          _start = verse;
          _end = _tempEnd;
          _selectionMode = null;
        });
      }

      if (_selectionMode == SelectionMode.end) {
        if (verse < _tempStart) _tempStart = verse;
        setState(() {
          _end = verse;
          _start = _tempStart;
          _selectionMode = null;
        });
      }
      _player.play();
      return;
    }

    if (isolatedVers != null) {
      setState(() {
        isolatedVers = null;
      });
      return;
    }

    if (verse == _currentVerse) {
      print('** ACTIVATER ISOLAITION MODE for vers $verse');
      setState(() {
        isolatedVers = verse;
      });
      return;
    }

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
                  controller: _controller,
                  child: QuranText(
                    surahNumber: _surahNumber,
                    start: _start,
                    end: _end,
                    current: _currentVerse,
                    tap: onSelect,
                    isSelecting: _selectionMode != null,
                    isolatedVers: isolatedVers,
                  ),
                ),
              ),
            ),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey,
              child: _selectionMode != null
                  ? _showSelectPanel()
                  : _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipButton(
                              onIncrement: incrementStart,
                              onDecrement: decrementStart,
                              onSelect: _selectStart,
                              aya: _start,
                            ),
                            IconButton(
                              onPressed: () => setState(() {
                                _player.playing
                                    ? _player.pause()
                                    : _player.play();
                              }),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _player.playing
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 48,
                              ),
                            ),
                            ClipButton(
                              onIncrement: incrementEnd,
                              onDecrement: decrementEnd,
                              onSelect: _selectEnd,
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

  Widget _showSelectPanel() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('select a verse.'),
        ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              setState(() {
                _selectionMode = null;
                _start = _tempStart;
                _end = _tempEnd;
              });
              _player.play();
            }),
      ],
    );
  }

  void _save() {
    Provider.of<Prevs>(context, listen: false).saveLatest(Clip(
      surahNumber: _surahNumber,
      start: _start,
      end: _end,
    ));
  }

  void incrementStart() async {
    if (_start >= _positions.length - 1) return;

    setState(() {
      _start++;
      if (_start > _end) _end++;
    });

    if (_start <= _currentVerse) return;
    _currentVerse = _start;
    await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));

    _save();
  }

  void decrementStart() async {
    if (_start <= 1) return;
    setState(() {
      _start = _start - 1;
    });

    _save();
  }

  void incrementEnd() async {
    if (_end >= _positions.length - 1) return;
    setState(() {
      _end = _end + 1;
    });

    _save();
  }

  void decrementEnd() async {
    if (_end <= 1) return;
    setState(() {
      _end--;
      if (_end <= _start) _start = _end;
      if (_end < _currentVerse) {
        _currentVerse = _start;
        _player.seek(Duration(milliseconds: _positions[_start - 1]));
      }
    });
    _save();
  }

  void _selectStart() {
    _player.pause();
    setState(() {
      _selectionMode = SelectionMode.start;

      _tempStart = _start;
      _tempEnd = _end;
      _start = 1;
      _end = _positions.length - 1;
    });
    print(_selectionMode);
  }

  void _selectEnd() {
    _player.pause();
    setState(() {
      _selectionMode = SelectionMode.end;

      _tempStart = _start;
      _tempEnd = _end;
      _start = 1;
      _end = _positions.length - 1;
    });
    print(_selectionMode);
  }
}
