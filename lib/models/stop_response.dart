import 'package:arebbus/models/stop.dart';

class StopResponse {
  final List<Stop> stops;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  StopResponse({
    required this.stops,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory StopResponse.fromJson(Map<String, dynamic> json) {
    return StopResponse(
      stops: (json['stops'] as List)
          .map((stop) => Stop.fromJson(stop as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}