import 'dart:convert';

import 'package:http/http.dart' as http;

class Timing {
  final int surahId;

  // final int reciterId;
  Timing({
    required this.surahId,
  });

  Future<List<int>> fetchTiming() async {
    int reciterId = 10;
    final url =
        'https://api.qurancdn.com/api/qdc/audio/reciters/$reciterId/audio_files?chapter=$surahId&segments=true';
    final res = await http.get(Uri.parse(url));
    List data = jsonDecode(res.body)['audio_files'][0]['verse_timings'];
    // print(data.toString());
    List<int> timing = data.map((e) => e['timestamp_to'] as int).toList();

    print(timing);
    return [0, ...timing];
  }
}
