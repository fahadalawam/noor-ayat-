import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class TextPage extends StatelessWidget {
  const TextPage({Key? key}) : super(key: key);

  Future<String> getText() async {
    final res = await http.get(
        Uri.parse('https://quran.com/fonts/quran/hafs/v1/woff2/p562.woff2'));
    print(res.body.toString());
    return 'hello';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: getText(),
            builder: (context, snapshot) {
              String text =
                  snapshot.data == null ? 'ok' : snapshot.data.toString();

              return Text(text);
            }),
      ),
    );
  }
}
