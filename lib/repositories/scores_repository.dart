import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/score.dart';

class ScoresRepository {
  static Stream<Iterable<Score>> getScores() => FirebaseFirestore.instance
      .collection('scores')
      .orderBy('dateTime', descending: true)
      .snapshots()
      .asyncMap(_toScores);

  static Iterable<Score> _toScores(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> document) =>
          Score.fromJson(document.data() ?? <String, dynamic>{}));
}
