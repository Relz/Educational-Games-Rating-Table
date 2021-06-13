import 'package:cloud_firestore/cloud_firestore.dart';

class Score {
  const Score({
    required this.value,
    required this.nickName,
    required this.gameId,
    required this.sessionId,
    required this.dateTime,
  });

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        value: json['value'] ?? 0,
        nickName: json['nickName'] ?? '',
        gameId: json['gameId'] ?? '',
        sessionId: json['sessionId'] ?? '',
        dateTime: (json['dateTime'] ?? Timestamp.now()).toDate(),
      );

  final int value;
  final String nickName;
  final String gameId;
  final String sessionId;
  final DateTime dateTime;
}

extension ScoreListExtension on List<Score> {
  double get averageValue =>
      fold<double>(
        0,
        (double value, Score score) => value + score.value,
      ) /
      length;

  Iterable<String> get gameIds => map((Score score) => score.gameId);
}
