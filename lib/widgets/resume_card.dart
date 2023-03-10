import 'package:flutter/material.dart';

import '../providers/prevs.dart';
import '../pages/player_page.dart';
import 'package:quran/quran.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ResumeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final clip = Provider.of<Prevs>(context).lastSave;
    if (clip == null) return Container();

    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        color: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('سورة ${getSurahNameArabic(clip.surahNumber)}  .  ${clip.reciter}'),
            subtitle: Text('${clip.start} - ${clip.end}'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerPage(
                          surahNumber: clip.surahNumber,
                          start: clip.start,
                          end: clip.end,
                        ))),
          ),
        ),
      ),
    );
  }
}
