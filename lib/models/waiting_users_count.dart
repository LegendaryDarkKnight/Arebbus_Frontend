class WaitingUsersCount {
  final int busId;
  final String busName;
  final int waitingCount;

  WaitingUsersCount({
    required this.busId,
    required this.busName,
    required this.waitingCount,
  });

  factory WaitingUsersCount.fromJson(Map<String, dynamic> json) {
    return WaitingUsersCount(
      busId: json['busId'],
      busName: json['busName'],
      waitingCount: json['waitingCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'busName': busName,
      'waitingCount': waitingCount,
    };
  }
}