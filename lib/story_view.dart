import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gladstoriesengine/gladstoriesengine.dart';
import 'package:litelocadeserta/bordered_container.dart';
import 'package:litelocadeserta/fat_container.dart';
import 'package:litelocadeserta/slidable_button.dart';

class StoryView extends StatefulWidget {
  final Story story;

  StoryView({
    this.story,
  });

  @override
  State<StatefulWidget> createState() => PassageState();
}

class PassageState extends State<StoryView> with TickerProviderStateMixin {
  ScrollController _passageScrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HistoryItem>>(
      stream: widget.story.historyChanges,
      initialData: widget.story.history,
      builder: (context, snapshot) {
        var history = snapshot.data;
        return Column(
          children: [
            _buildTextSection(history, context),
            if (widget.story.canContinue()) createContinue(context),
            if (!widget.story.canContinue())
              ...createOptionList(widget.story.currentPage.next),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        );
      },
    );
  }

  void _next(context) async {
    setState(() {
      widget.story.doContinue();
    });
  }


  List<Widget> createOptionList(List<PageNext> nextPages) {
    return nextPages.map((page) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.075,
          child: BorderedContainer(
            child: SlideableButton(
              onPress: () {
                if (!kIsWeb) {
                  HapticFeedback.mediumImpact();
                }
                setState(() {
                  widget.story.goToNextPage(page);
                });
              },
              child: FatContainer(
                text: page.text,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget createContinue(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: BorderedContainer(
        child: SlideableButton(
            child: FatContainer(
              text: 'Далі',
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPress: () {
              _next(context);
            }),
      ),
    );
  }

  Widget _buildTextSection(List<HistoryItem> history, BuildContext context) {
    Future.delayed(Duration(milliseconds: 300), _scroll(context));
    return Expanded(
        child: SingleChildScrollView(
          controller: _passageScrollController,
          child: Column(
            children: [
              ...history
                  .map(
                    (HistoryItem historyItem) => PassageItemView(
                  historyItem,
                ),
              )
                  .toList(),
              if (!widget.story.canContinue() &&
                  widget.story.currentPage.isTheEnd())
                BorderedContainer(
                  child: SlideableButton(
                    child:
                    FatContainer(text: 'Почати заново?'),
                    onPress: () {
                      widget.story.reset();
                    },
                  ),
                ),
            ],
          ),
        ));
  }

  _scroll(BuildContext context) {
    return () {
      if (_passageScrollController.hasClients) {
        var position = _passageScrollController.position;
        _passageScrollController.animateTo(
          position.maxScrollExtent,
          duration: Duration(milliseconds: 50),
          curve: Curves.easeOutBack,
        );
      }
    };
  }
}

class PassageItemView extends StatelessWidget {
  final HistoryItem historyItem;

  PassageItemView(this.historyItem);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: getDecorationForContainer(context),
          child: Text(
            historyItem.text == "" ? "The End" : historyItem.text,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      ],
    );
  }
}

BoxDecoration getDecorationForContainer(BuildContext context) => BoxDecoration(
  color: Theme.of(context).backgroundColor,
  border: Border.all(
    color: Theme.of(context).primaryColor,
    width: 3.0,
  ),
);