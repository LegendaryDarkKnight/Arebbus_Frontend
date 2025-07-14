import 'package:arebbus/models/bus.dart';

class BusResponse {
  final List<Bus> buses;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  BusResponse({
    required this.buses,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory BusResponse.fromJson(Map<String, dynamic> json) {
    return BusResponse(
      buses: (json['buses'] as List<dynamic>)
          .map((busJson) => Bus.fromJson(busJson as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buses': buses.map((bus) => bus.toJson()).toList(),
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}