class AverageScore {
  const AverageScore({
    required this.value,
    required this.nickName,
    required this.gameIds,
  });

  final double value;
  final String nickName;
  final Iterable<String> gameIds;
}
