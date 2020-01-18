import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:gladstoriesengine/gladstoriesengine.dart';
import 'package:http/http.dart' as http;
import 'package:litelocadeserta/story_view.dart';

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final AsyncMemoizer _storyGet = AsyncMemoizer();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchData(),
      builder: (BuildContext context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          case ConnectionState.done:
            print(snapshot);
            var story = Story.fromJson(snapshot.data.body);
            return StoryView(story: story);
        }
        return null;
      },
    );
  }

  Future _fetchData() async {
    return _storyGet.runOnce(() async {
      var result = await http
          .get('https://locadeserta.com/stories/published/krivava_pastka.json');

      return result;
    });
  }
}
