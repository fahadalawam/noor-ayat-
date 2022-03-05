import 'package:flutter/material.dart';

import 'package:ayat/pages/player_page.dart';

class ResumeCard extends StatelessWidget {
  final String surah;
  final String reciter;
  final int start;
  final int end;

  const ResumeCard({
    Key? key,
    required this.surah,
    required this.reciter,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        color: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('سورة $surah  .  $reciter'),
            subtitle: Text('$start - $end'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerPage(
                          surahNumber: 57,
                          start: start,
                          end: end,
                        ))),
          ),
        ),
      ),
    );
  }
}
