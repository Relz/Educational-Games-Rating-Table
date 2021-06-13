import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:educational_games_rating_table/core/layout/adaptive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'models/average_score.dart';
import 'models/score.dart';
import 'repositories/scores_repository.dart';
import 'widgets/app_bar_title.dart';
import 'widgets/loading.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Рейтинговая таблица обучающих игр';

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _title,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const MyHomePage(title: _title),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static const Color _appBarColor = Color(0xFF0F7375);
  static const Map<String, String> _gameIdToGameNameMap = <String, String>{
    'Bugs': 'Жуки',
    'ElectricCharge': 'Электрический заряд',
    'Pyramid': 'Пирамида',
  };

  static const ScrollPhysics _tabPhysics = NeverScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<FirebaseApp>(
          future: Firebase.initializeApp(),
          builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Что-то пошло не так ;(',
                  style: Theme.of(context).textTheme.headline5,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading(message: widget.title);
            }

            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxIsScrolled,
                ) =>
                    <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: MultiSliver(
                      children: <Widget>[
                        _buildAppBar(),
                        _buildListHeaderRow(),
                      ],
                    ),
                  ),
                ],
                body: StreamBuilder<Iterable<Score>>(
                  stream: ScoresRepository.getScores(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Iterable<Score>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Не удалось загрузить данные ;(',
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loading(
                        message: 'Подождите, загружаются данные',
                      );
                    }

                    final Iterable<Score>? scores = snapshot.data;

                    if (scores == null) {
                      return Center(
                        child: Text(
                          'Не удалось загрузить данные ;(',
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final Iterable<AverageScore> userAverageScores =
                        _getAverageScores(scores);

                    return TabBarView(
                      physics: _tabPhysics,
                      children: <Widget>[
                        CustomScrollView(
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) =>
                                    _buildScoresListRow(
                                  scores.elementAt(index),
                                  index.isOdd,
                                ),
                                childCount: scores.length,
                              ),
                            ),
                          ],
                        ),
                        CustomScrollView(
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) =>
                                    _buildAverageScoresListRow(
                                  userAverageScores.elementAt(index),
                                  index.isOdd,
                                ),
                                childCount: userAverageScores.length,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

  Widget _buildAppBar() => SliverAppBar(
        pinned: true,
        expandedHeight: 200,
        backgroundColor: _appBarColor,
        flexibleSpace: FlexibleSpaceBar(
          title: AppBarTitle(title: widget.title, color: _appBarColor),
          centerTitle: true,
          titlePadding: const EdgeInsets.only(
            bottom: 8.0 * 7,
            left: 8.0 * 2,
            right: 8.0 * 2,
            top: 8,
          ),
          background: const DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[_appBarColor, Colors.transparent],
              ),
            ),
            child: Image(
              image: AssetImage('images/appbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        bottom: const TabBar(
          physics: _tabPhysics,
          tabs: <Tab>[
            Tab(text: 'Все игровые сессии'),
            Tab(text: 'Средний рейтинг по каждому игроку'),
          ],
        ),
      );

  Widget _buildListHeaderRow() => SliverAppBar(
        pinned: true,
        backgroundColor: const Color(0xFFE4FFFF),
        title: SizedBox(
          height: 18,
          child: TabBarView(
            physics: _tabPhysics,
            children: <Widget>[
              _buildScoresListHeaderRow(),
              _buildAverageScoresListHeaderRow(),
            ],
          ),
        ),
      );

  Widget _buildScoresListHeaderRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: _buildListRowText(
              'Игрок',
              textAlign: TextAlign.start,
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildListRowText(
              'Игра',
              textAlign: TextAlign.start,
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildListRowText(
              'Рейтинг',
              textAlign: TextAlign.center,
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildListRowText(
              'Время',
              textAlign: TextAlign.end,
              isBold: true,
            ),
          ),
        ],
      );

  Widget _buildAverageScoresListHeaderRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: _buildListRowText(
              'Игрок',
              textAlign: TextAlign.start,
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildListRowText(
              'Игра',
              textAlign: TextAlign.start,
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildListRowText(
              'Рейтинг',
              textAlign: TextAlign.center,
              isBold: true,
            ),
          ),
        ],
      );

  Iterable<AverageScore> _getAverageScores(Iterable<Score> scores) => groupBy(
        scores,
        (Score score) => score.nickName,
      )
          .map<String, AverageScore>(
            (String nickName, List<Score> scores) =>
                MapEntry<String, AverageScore>(
              nickName,
              AverageScore(
                value: scores.averageValue,
                nickName: nickName,
                gameIds: scores.gameIds.toSet(),
              ),
            ),
          )
          .values;

  Widget _buildScoresListRow(Score score, bool isOdd) => Container(
        color: isOdd ? Colors.grey.withOpacity(0.1) : null,
        padding: const EdgeInsets.all(8.0 * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: _buildListRowText(
                score.nickName,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: _buildListRowText(
                _convertGameIdToGameName(score.gameId),
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: Center(child: _buildStarIcons(score.value)),
            ),
            Expanded(
              child: _buildListRowText(
                _formatDateTime(score.dateTime),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );

  Widget _buildAverageScoresListRow(AverageScore score, bool isOdd) =>
      Container(
        color: isOdd ? Colors.grey.withOpacity(0.1) : null,
        padding: const EdgeInsets.all(8.0 * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: _buildListRowText(
                score.nickName,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: _buildListRowText(
                score.gameIds.map(_convertGameIdToGameName).join(', '),
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: Center(child: _buildStarIcons(score.value)),
            ),
          ],
        ),
      );

  String _convertGameIdToGameName(String gameId) =>
      _gameIdToGameNameMap[gameId] ?? gameId;

  Widget _buildListRowText(
    String text, {
    TextAlign? textAlign,
    bool? isBold,
  }) {
    final FontWeight fontWeight =
        (isBold ?? false) ? FontWeight.bold : FontWeight.normal;
    final TextStyle? textStyle =
        Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: fontWeight);

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
    );
  }

  Widget _buildStarIcons(num scoreValue) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildStarIcon(Icons.star),
          _buildStarIcon(scoreValue >= 2
              ? Icons.star
              : scoreValue >= 1.5
                  ? Icons.star_half
                  : Icons.star_outline),
          _buildStarIcon(scoreValue == 3
              ? Icons.star
              : scoreValue >= 2.5
                  ? Icons.star_half
                  : Icons.star_outline),
        ],
      );

  Widget _buildStarIcon(IconData icon) => Icon(
        icon,
        color: Colors.yellow[800],
        size: 8.0 * 2,
      );

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
}
