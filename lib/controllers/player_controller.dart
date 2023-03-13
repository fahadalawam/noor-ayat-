import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/timing.dart';

enum SelectionMode { start, end }

enum DelayMode { noDelay, everAya, endOfLoop }

class PlayerController extends ChangeNotifier {
  late AudioPlayer _player;
  DelayMode _delayMode = DelayMode.noDelay;
  SelectionMode? _selectionMode;

  late int _surahNumber;
  late String _reciter;
  late int _start;
  late int _end;
  int? _isolatedVers;

  bool _isLoading = true;
  bool _isPlayig = false;
  bool _isUserPause = false;

  late int _currentVerse;

  late List<int> _positions;
  late SharedPreferences _sp;

  get isPlaying => _isPlayig;
  bool get isLoading => _isLoading;
  bool get isUserPause => _isUserPause;
  int get currentVeres => _currentVerse;
  int? get isolatedVers => _isolatedVers;

  int get start => _start;
  int get end => _end;

  SelectionMode? get selectionMode => _selectionMode;
  DelayMode get currentDelayMode => _delayMode;

  Future<void> initPlayer({required int surahNumber, required int start, required int end}) async {
    _surahNumber = surahNumber;
    _start = start;
    _end = end;

    _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    // TODO: impliment change reciter function.
    _sp = await SharedPreferences.getInstance();
    _reciter = _sp.getString('reciter') ?? 'saud_ash-shuraym';

    await _player.setUrl(_getAudio(_surahNumber, _reciter));

    _startPositionStream();

    _positions = await Timing(surahId: _surahNumber).fetchTiming();
    _isLoading = false;

    goto(_start);
    resume();
  }

  _startPositionStream() {
    _player.onAudioPositionChanged.listen((event) {
      int pos = event.inMilliseconds;

      if (pos >= _positions[_currentVerse]) {
        print('ayyya');
        _goToNextVeres();
      }

      if (pos > _positions[_end]) {
        print('enddddd');

        _goToFirstVerse();
      }
    });
  }

  Future<void> _startAyaDelay() async {
    pause();
    final prevDuration = _currentVerse == 0 ? 0 : _positions[_currentVerse - 1];
    await Future.delayed(Duration(milliseconds: _positions[_currentVerse] - prevDuration));
  }

  Future<void> _startEndDelay() {
    pause();
    final delay = _positions[_end] - _positions[_start];
    return Future.delayed(Duration(milliseconds: delay));
  }

  void _goToFirstVerse() async {
    if (_delayMode == DelayMode.endOfLoop) await _startEndDelay();

    goto(_start);

    pause();
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 1000));

    _isLoading = false;
    resume();
  }

  void _goToNextVeres() async {
    //TODO: refactor this.
    if (_delayMode == DelayMode.everAya) await _startAyaDelay();
    _currentVerse++;

    if (_delayMode == DelayMode.everAya) resume();
    notifyListeners();
  }

  void changeLoopLength(int selection) async {
    if (_selectionMode == SelectionMode.start) {
      if (selection > _tempEnd) _tempEnd = selection;

      setState(() {
        _start = selection;
        _end = _tempEnd;
        _currentVerse = _start;
        _selectionMode = null;
      });
    } else if (_selectionMode == SelectionMode.end) {
      if (selection < _tempStart) _tempStart = selection;

      setState(() {
        _end = selection;
        _start = _tempStart;
        _currentVerse = _start;
        _selectionMode = null;
      });
    }

    await _player.seek(Duration(milliseconds: _positions[_currentVerse - 1]));
    _player.resume();
  }

  void pp() {
    if (_player.state == PlayerState.PLAYING) {
      _player.pause();
      _isUserPause = true;
      _isPlayig = false;
    } else {
      _player.resume();
      _isUserPause = false;
      _isPlayig = true;
    }
    notifyListeners();
  }

  void resume() {
    if (_isUserPause) return;

    _player.resume();
    _isPlayig = true;
    notifyListeners();
  }

  void pause() {
    _player.pause();
    _isPlayig = false;
    notifyListeners();
  }

  void goto(int verse) async {
    await _player.seek(Duration(milliseconds: _positions[verse - 1]));
    _currentVerse = verse;
    notifyListeners();
  }

  void dispose() {
    _player.stop();
    _player.dispose();
    notifyListeners();
  }

  void changeDelayMode(DelayMode? selected) {
    if (selected == null) return;

    _delayMode = selected;
    notifyListeners();
  }

  void changeSelectionMode(SelectionMode? mode) {
    _selectionMode = mode;
    notifyListeners();
  }

  void setIsolatedVers(int? vers) {
    _isolatedVers = vers;
    notifyListeners();
  }

  String _getAudio(surah, reciter) {
    String s = surah;
    if (reciter == 'saud_ash-shuraym') s = s.toString().padLeft(3, '0');

    return 'https://download.quranicaudio.com/qdc/$reciter/murattal/$s.mp3';
  }

  void incrementStart() async {
    if (_start >= _positions.length - 1) return;

    _start++;
    if (_start > _end) _end++;

    if (_start <= _currentVerse) return;

    _currentVerse = _start;
    goto(_currentVerse);
    notifyListeners();

    _save();
  }

  void decrementStart() async {
    if (_start <= 1) return;

    _start--;
    notifyListeners();

    _save();
  }

  void incrementEnd() async {
    if (_end >= _positions.length - 1) return;

    _end++;
    notifyListeners();

    _save();
  }

  void decrementEnd() async {
    if (_end <= 1) return;

    _end--;
    if (_end <= _start) _start = _end;

    if (_end < _currentVerse) {
      _currentVerse = _start;
      goto(_start);
    }
    notifyListeners();

    _save();
  }

  void _selectStart() {
    pause();

    _selectionMode = SelectionMode.start;

    _tempStart = _start;
    _tempEnd = _end;
    _start = 1;
    _end = _positions.length - 1;

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
