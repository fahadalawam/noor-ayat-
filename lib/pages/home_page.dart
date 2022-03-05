import 'package:ayat/pages/player_page.dart';
import 'package:flutter/material.dart';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';

import '../widgets/statics_card.dart';
import '../widgets/resume_card.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();

  final bool _isOk = true;

  @override
  Widget build(BuildContext context) {
    // final List _list = List.generate(20, (index) => index);
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
                  if (_isOk)
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
                  const ResumeCard(
                    surah: 'الحديد',
                    reciter: 'سعد الغامدي',
                    start: 10,
                    end: 15,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            SliverGrid(
              delegate: SliverChildListDelegate(
                List.generate(100, (index) => index + 1)
                    .map((e) => InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerPage(
                                surahNumber: e,
                                start: 1,
                                end: 3,
                              ),
                            ),
                          ),
                          child: Card(
                            color: Colors.blue,
                            // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Container(
                              // margin: const EdgeInsets.all(4),
                              child: Text(
                                e.toString(),
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
