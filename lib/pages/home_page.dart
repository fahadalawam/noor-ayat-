import '../pages/player_page.dart';
import '../providers/prevs.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';

import 'package:quran/quran.dart' as quran;

import '../widgets/statics_card.dart';
import '../widgets/resume_card.dart';

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final prev = Provider.of<Prevs>(context).lastSave;

    print(prev.toString());
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 20),
                  const StaticsCard(),
                  const StaticsCard(height: 50),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(10, (index) => index).map((index) {
                        return Container(
                          width: 100,
                          height: 50,
                          color: Colors.blue,
                          margin: const EdgeInsets.all(2),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ResumeCard(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            SliverGrid(
              delegate: SliverChildListDelegate(
                List.generate(114, (index) => index + 1)
                    .map((i) => InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerPage(
                                surahNumber: i,
                                start: 1,
                                end: 3,
                              ),
                            ),
                          ).then((value) => print('back ====')),
                          child: Card(
                            color: Colors.blue,
                            // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Container(
                              // margin: const EdgeInsets.all(4),
                              child: Text(
                                quran.getSurahNameArabic(i),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // mainAxisSpacing: 2,
                // crossAxisSpacing: 10,
                childAspectRatio: 2 / 1,
                // mainAxisExtent: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
