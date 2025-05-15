// lib/models/user_model.dart
class ArebbuUser {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl; // Mock
  int reputationPoints;
  final List<String> subscribedRoutes; // List of route IDs or names
  final List<String> contributedAddons; // List of addon IDs or names

  ArebbuUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    this.reputationPoints = 0,
    this.subscribedRoutes = const [],
    this.contributedAddons = const [],
  });
}
