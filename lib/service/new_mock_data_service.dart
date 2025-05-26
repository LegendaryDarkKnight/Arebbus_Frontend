// lib/services/mock_data_service.dart
import 'package:arebbus/models/addon_category.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/models/addon.dart';

class NewMockDataService {
  static final String placeHolder = 'https://picsum.photos/200';
  static final User currentUser = User(
    id: 1,
    name: 'Imtiaz',
    email: 'imtiaz@buet.ac.bd',
    image: placeHolder, // Teal background, white text
    reputation: 150,
    valid: true,
  );


  static List<Addon> getMockAddons() {
    return [
      Addon(
        id: 'addon_1',
        name: 'City Center Stop',
        description: 'Main bus stop in downtown area',
        category: AddonCategory.stop,
        author: currentUser,
        installs: 1500,
        rating: 4.5,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Addon(
        id: 'addon_2',
        name: 'Suburban Route',
        description: 'Route connecting city to suburbs',
        category: AddonCategory.route,
        author: currentUser,
        installs: 800,
        rating: 4.2,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Addon(
        id: 'addon_3',
        name: 'Express Bus Service',
        description: 'Fast bus service for Route A',
        category: AddonCategory.route,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 2000,
        rating: 4.8,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Addon(
        id: 'addon_4',
        name: 'Real-time Navigation',
        description: 'Live navigation for bus routes',
        category: AddonCategory.stop,
        author: User(name: "Jaden Smith",email: "jadensmith@gmail.com", reputation: 100, image: placeHolder, valid: true),
        installs: 1200,
        rating: 4.0,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Addon(
        id: 'addon_5',
        name: 'Community Chat',
        description: 'Chat with other commuters',
        category: AddonCategory.bus,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 500,
        rating: 3.8,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Addon(
        id: 'addon_6',
        name: 'Traffic Alerts',
        description: 'Real-time traffic and delay alerts',
        category: AddonCategory.stop,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 3000,
        rating: 4.7,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Addon(
        id: 'addon_7',
        name: 'Northside Stop',
        description: 'Bus stop in north residential area',
        category:AddonCategory.stop,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 600,
        rating: 4.1,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Addon(
        id: 'addon_8',
        name: 'Night Route',
        description: 'Late-night bus route',
        category: AddonCategory.route,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 400,
        rating: 3.9,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
