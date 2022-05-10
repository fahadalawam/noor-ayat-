import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clip.dart';

class Prevs with ChangeNotifier {
  Clip? _lastSave;

  Clip? get lastSave {
    if (_lastSave != null) return _lastSave;
    _loadClip().then((value) {
      _lastSave = value;
      notifyListeners();
    });
  }

  Future<Clip> _loadClip() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int surah = preferences.getInt('surahNumber') ?? 1;
    int start = preferences.getInt('start') ?? 1;
    int end = preferences.getInt('end') ?? 1;
    return Clip(surahNumber: surah, start: start, end: end);
  }

  void saveLatest(Clip? clip) {
    _lastSave = clip;
    _save(_lastSave);
    notifyListeners();
  }

  Future<void> _save(Clip? clip) async {
    print('saving pref..');
    if (clip == null) {
      print('cant save, clip = null');
      return;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('surahNumber', clip.surahNumber);
    preferences.setInt('start', clip.start);
    preferences.setInt('end', clip.end);
    print('saved pref :)');
  }
}
