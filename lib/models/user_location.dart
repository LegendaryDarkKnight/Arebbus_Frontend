class UserLocation {
  final int userId;
  final int? busId;
  final String? busName;
  final double latitude;
  final double longitude;
  final String time;
  final String status;

  UserLocation({
    required this.userId,
    this.busId,
    this.busName,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.status,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId'],
      busId: json['busId'],
      busName: json['busName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      time: json['time'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'busId': busId,
      'busName': busName,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
      'status': status,
    };
  }

  bool get isNoTrack => status == 'NO_TRACK';
  bool get isWaiting => status == 'WAITING';
  bool get isOnBus => status == 'ON_BUS';
}