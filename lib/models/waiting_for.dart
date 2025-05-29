import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/user.dart';

class WaitingFor {
  final int userId;
  final int busId;
  final bool valid;
  final User? user;
  final Bus? bus;

  WaitingFor({
    required this.userId,
    required this.busId,
    required this.valid,
    this.user,
    this.bus,
  });

  factory WaitingFor.fromJson(Map<String, dynamic> json) {
    return WaitingFor(
      userId: json['user_id'] ?? json['userId'],
      busId: json['bus_id'] ?? json['busId'],
      valid: json['valid'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'valid': valid,
      'user': user?.toJson(),
      'bus': bus?.toJson(),
    };
  }

  WaitingFor copyWith({
    int? userId,
    int? busId,
    bool? valid,
    User? user,
    Bus? bus,
  }) {
    return WaitingFor(
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      valid: valid ?? this.valid,
      user: user ?? this.user,
      bus: bus ?? this.bus,
    );
  }

  @override
  String toString() {
    return 'WaitingFor{userId: $userId, busId: $busId, valid: $valid}';
  }
}

