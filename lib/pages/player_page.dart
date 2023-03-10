import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:quran/quran.dart' as quran;

import '../providers/prevs.dart';
import '../models/clip.dart';
import '../utils/timing.dart';
import '../widgets/quran_text.dart';
import '../widgets/clip_button.dart';

enum SelectionMode { start, end }

enum DelayMode { noDelay, everAya, endOfLoop }

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
  DelayMode _delayMode = DelayMode.noDelay;

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
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    String s = _surahNumber.toString().padLeft(3, '0');
    _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    await _player.setUrl('https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/$s.mp3');

    await Timing(surahId: _surahNumber).fetchTiming().then((value) {
      setState(() {
        _positions = value;
        _isLoading = false;
        _player.seek(Duration(milliseconds: _positions[_start - 1]));
        _player.resume();
      });
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    final delayModeIndex = sp.getInt('delayModeIndex') ?? 0;

    setState(() {
      _delayMode = DelayMode.values.elementAt(delayModeIndex);
    });

    int _tick = 50;
    _timer = Timer.periodic(Duration(milliseconds: _tick), (Timer t) async {
      if (_player.state == PlayerState.PLAYING) {
        final position = await _player.getCurrentPosition();

        if (position >= _positions[_currentVerse]) {
          print('ayyya');
          _goToNextVeres();
        }

        if (position > _positions[_end]) {
          print('enddddd');

          _goToFirstVerse();
        }
      }
    });
  }

  Future<void> _startAyaDelay() async {
    _player.pause();
    final prevDuration = _currentVerse == 0 ? 0 : _positions[_currentVerse - 1];
    await Future.delayed(Duration(milliseconds: _positions[_currentVerse] - prevDuration));
  }

  Future<void> _startEndDelay() {
    _player.pause();

    final delay = _positions[_end] - _positions[_start];
    return Future.delayed(Duration(milliseconds: delay));
  }

  void _goToFirstVerse() async {
    if (_delayMode == DelayMode.endOfLoop) await _startEndDelay();

    _player.seek(Duration(milliseconds: _positions[_start - 1]));
    setState(() {
      _currentVerse = _start;
      _player.pause();
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _isLoading = false;
      _player.resume();
    });
  }

  void _goToNextVeres() async {
    if (_delayMode == DelayMode.everAya) await _startAyaDelay();
    setState(() {
      _currentVerse++;
    });
    if (_delayMode == DelayMode.everAya) _player.resume();
  }

  void onSelect(int verse) async {
    if (_selectionMode != null) {
      if (_selectionMode == SelectionMode.start) {
        if (verse > _tempEnd) _tempEnd = verse;
        setState(() {
          _start = verse;
          _end = _tempEnd;
          _currentVerse = _start;
          _selectionMode = null;
        });
      }

      if (_selectionMode == SelectionMode.end) {
        if (verse < _tempStart) _tempStart = verse;
        setState(() {
          _end = verse;
          _start = _tempStart;
          _currentVerse = _start;
          _selectionMode = null;
        });
      }

      await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
      _player.resume();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<DelayMode>(
                  onChanged: (val) async {
                    setState(() {
                      if (val != null) _delayMode = val;
                    });
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    sp.setInt('delayModeIndex', _delayMode.index);
                  },
                  value: _delayMode,
                  items: [
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
                const SizedBox(width: 30),
                DropdownButton<DelayMode>(
                  onChanged: (val) async {
                    setState(() {
                      if (val != null) _delayMode = val;
                    });
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    sp.setInt('delayModeIndex', _delayMode.index);
                  },
                  value: _delayMode,
                  items: [
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
                            Column(
                              children: [
                                IconButton(onPressed: () {}, icon: Icon(Icons.keyboard_double_arrow_up_rounded)),
                                IconButton(
                                  // onPressed: () {},
                                  onPressed: () => setState(() {
                                    _player.state == PlayerState.PLAYING ? _player.pause() : _player.resume();
                                  }),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    _player.state == PlayerState.PLAYING ? Icons.pause : Icons.play_arrow,
                                    size: 48,
                                  ),
                                ),
                              ],
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
              // _player.play();
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
