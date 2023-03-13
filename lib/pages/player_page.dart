import 'dart:async';
import 'package:ayat/controllers/player_controller.dart';

import '../models/clip.dart';
import '../providers/prevs.dart';
import '../utils/timing.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;
import 'package:wakelock/wakelock.dart';

import 'package:provider/provider.dart';

import '../widgets/quran_text.dart';
import '../widgets/clip_button.dart';

// import 'package:shared_preferences/shared_preferences.dart';

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
  // late AudioPlayer _player;
  // late AudioPlayer _clip;
  // late int? _duration;
  late PlayerController _pc;
  late int _surahNumber;
  late int _start;
  late int _end;
  late int _tempStart;
  late int _tempEnd;
  late int _currentVerse;
  late ScrollController _controller;
  late List<int> _positions;

  bool _isLoading = false;

  late Timer _timer;

  int? isolatedVers;
  // SelectionMode? _selectionMode;

  @override
  void initState() {
    super.initState();
    Wakelock.toggle(enable: true);
    _surahNumber = widget.surahNumber;
    _start = widget.start;
    _currentVerse = _start;
    _end = widget.end;
    // _player = AudioPlayer();
    _pc = PlayerController();

    _controller = ScrollController();
  }

  @override
  void dispose() {
    print('dispos...');
    Wakelock.toggle(enable: false);
    _pc.dispose();
    // _player.stop();
    // _player.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // String s = _surahNumber.toString().padLeft(3, '0');
    // String s = _surahNumber.toString();
    // _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    // await _player.setUrl('https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/$s.mp3');
    await _pc.initPlayer(
      surahNumber: widget.surahNumber,
      start: widget.start,
      end: widget.end,
    );

    // await Timing(surahId: _surahNumber).fetchTiming().then((value) {
    //   setState(() {
    //     _positions = value;
    //     _isLoading = false;

    //     _playerController.goto(_start);

    //     _player.resume();
    //   });
    // });

    // int _tick = 50;
    // TODO: change to stream;
    // _timer = Timer.periodic(Duration(milliseconds: _tick), (Timer t) async {
    //   if (_player.state == PlayerState.PLAYING) {
    //     final position = await _player.getCurrentPosition();

    //     if (position >= _positions[_currentVerse]) {
    //       print('ayyya');
    //       _goToNextVeres();
    //     }

    //     if (position > _positions[_end]) {
    //       print('enddddd');

    //       _goToFirstVerse();
    //     }
    //   }
    // });
  }

  // Future<void> _startAyaDelay() async {
  //   _player.pause();
  //   final prevDuration = _currentVerse == 0 ? 0 : _positions[_currentVerse - 1];
  //   await Future.delayed(Duration(milliseconds: _positions[_currentVerse] - prevDuration));
  // }

  // Future<void> _startEndDelay() {
  //   _player.pause();

  //   final delay = _positions[_end] - _positions[_start];
  //   return Future.delayed(Duration(milliseconds: delay));
  // }

  // void _goToFirstVerse() async {
  //   if (_delayMode == DelayMode.endOfLoop) await _startEndDelay();

  //   _player.seek(Duration(milliseconds: _positions[_start - 1]));
  //   setState(() {
  //     _currentVerse = _start;
  //     _player.pause();
  //     _isLoading = true;
  //   });
  //   await Future.delayed(const Duration(milliseconds: 1000));
  //   setState(() {
  //     _isLoading = false;
  //     _player.resume();
  //   });
  // }

  // void _goToNextVeres() async {
  //   if (_delayMode == DelayMode.everAya) await _startAyaDelay();
  //   setState(() {
  //     _currentVerse++;
  //   });
  //   if (_delayMode == DelayMode.everAya) _player.resume();
  // }

  // void _changeLoopLength(int selection) async {
  //   if (_selectionMode == SelectionMode.start) {
  //     if (selection > _tempEnd) _tempEnd = selection;

  //     setState(() {
  //       _start = selection;
  //       _end = _tempEnd;
  //       _currentVerse = _start;
  //       _selectionMode = null;
  //     });
  //   } else if (_selectionMode == SelectionMode.end) {
  //     if (selection < _tempStart) _tempStart = selection;

  //     setState(() {
  //       _end = selection;
  //       _start = _tempStart;
  //       _currentVerse = _start;
  //       _selectionMode = null;
  //     });
  //   }

  //   await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
  //   _player.resume();
  // }

  void _onTap(int verse) async {
    if (_pc.selectionMode != null) {
      _pc.changeLoopLength(verse);
      return;
    }

    if (_pc.isolatedVers != null) {
      _pc.setIsolatedVers(null);
      return;
    }

    if (verse == _pc.currentVeres) {
      print('** ACTIVATER ISOLAITION MODE for vers $verse');
      _pc.setIsolatedVers(verse);
      return;
    }

    _pc.goto(verse);
    // setState(() {
    //   _currentVerse = verse;
    // });
    // await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
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
            DropdownButton<DelayMode>(
              onChanged: (val) => _pc.changeDelayMode(val),
              value: _pc.currentDelayMode,
              items: const [
                DropdownMenuItem(
                  value: DelayMode.noDelay,
                  child: Text('لا تتوقف'),
                ),
                DropdownMenuItem(
                  value: DelayMode.everAya,
                  child: Text('بعد كل آية'),
                ),
                DropdownMenuItem(
                  value: DelayMode.endOfLoop,
                  child: Text('في النهاية'),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  controller: _controller,
                  child: QuranText(
                    surahNumber: _surahNumber,
                    start: _start,
                    end: _end,
                    current: _currentVerse,
                    tap: _onTap,
                    isSelecting: _pc.selectionMode != null,
                    isolatedVers: isolatedVers,
                  ),
                ),
              ),
            ),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey,
              child: _pc.selectionMode != null
                  ? _selectPanel()
                  : _pc.isLoading
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
                              // onPressed: () {},
                              onPressed: _pc.pp,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _pc.isPlaying ? Icons.pause : Icons.play_arrow,
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
            ),
          ],
        ),
      ),
    );
  }

// FIXME: complete implementation of change loop length function
  Widget _selectPanel() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('select a verse.'),
        ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              _pc.changeSelectionMode(null);
              _pc.resume();
              setState(() {
                // _selectionMode = null;
                _start = _tempStart
                _end = _tempEnd
                // _pc.resume();
              });
            }),
      ],
    );
  }

  void _save() {
    Provider.of<Prevs>(context, listen: false).saveLatest(
      Clip(
        surahNumber: _surahNumber,
        start: _start,
        end: _end,
      ),
    );
  }

  // void incrementStart() async {
  //   if (_start >= _positions.length - 1) return;

  //   setState(() {
  //     _start++;
  //     if (_start > _end) _end++;
  //   });

  //   if (_start <= _currentVerse) return;
  //   _currentVerse = _start;
  //   // await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
  //   _pc.goto(_currentVerse);

  //   _save();
  // }

  // void decrementStart() async {
  //   if (_start <= 1) return;
  //   setState(() {
  //     _start = _start - 1;
  //   });

  //   _save();
  // }

  // void incrementEnd() async {
  //   if (_end >= _positions.length - 1) return;
  //   setState(() {
  //     _end = _end + 1;
  //   });

  //   _save();
  // }

  // void decrementEnd() async {
  //   if (_end <= 1) return;
  //   setState(() {
  //     _end--;
  //     if (_end <= _start) _start = _end;
  //     if (_end < _currentVerse) {
  //       _currentVerse = _start;
  //       _player.seek(Duration(milliseconds: _positions[_start - 1]));
  //     }
  //   });
  //   _save();
  // }

  // void _selectStart() {
  //   _player.pause();
  //   setState(() {
  //     _selectionMode = SelectionMode.start;

  //     _tempStart = _start;
  //     _tempEnd = _end;
  //     _start = 1;
  //     _end = _positions.length - 1;
  //   });
  //   print(_selectionMode);
  // }

  // void _selectEnd() {
  //   _player.pause();
  //   setState(() {
  //     _selectionMode = SelectionMode.end;

  //     _tempStart = _start;
  //     _tempEnd = _end;
  //     _start = 1;
  //     _end = _positions.length - 1;
  //   });
  //   print(_selectionMode);
  // }
}
