import 'package:arebbus/models/addon_category.dart';
import 'package:arebbus/models/user.dart';

class Addon {
  final String id;
  final String name;
  final String description;
  final AddonCategory category;
  final User author;
  final int installs;
  final double rating;
  final bool isInstalled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.author,
    required this.installs,
    required this.rating,
    required this.isInstalled,
    required this.createdAt,
    required this.updatedAt,
  });
}
