import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/user.dart';

class Install {
  final int userId;
  final int busId;
  final User? user;
  final Bus? bus;

  Install({required this.userId, required this.busId, this.user, this.bus});

  factory Install.fromJson(Map<String, dynamic> json) {
    return Install(
      userId: json['user_id'] ?? json['userId'],
      busId: json['bus_id'] ?? json['busId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'user': user?.toJson(),
      'bus': bus?.toJson(),
    };
  }

  Install copyWith({int? userId, int? busId, User? user, Bus? bus}) {
    return Install(
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      user: user ?? this.user,
      bus: bus ?? this.bus,
    );
  }

  @override
  String toString() {
    return 'Install{userId: $userId, busId: $busId}';
  }
}
