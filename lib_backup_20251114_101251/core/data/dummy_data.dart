import 'package:girlsbandtabi_app/models/place.dart';

// Dummy data for development, as specified in the planning document.

class DummyData {
  static final List<Place> places = [
    const Place(
      id: '1',
      name: 'Shibuya O-EAST',
      description: 'A famous live house in Shibuya, known for rock and indie bands.',
      imageUrl: 'https://via.placeholder.com/400x300.png/007AFF/FFFFFF?text=O-EAST',
      latitude: 35.6617,
      longitude: 139.6995,
    ),
    const Place(
      id: '2',
      name: 'Shimokitazawa SHELTER',
      description: 'A legendary small live house in the heart of Shimokitazawa, the home of indie rock.',
      imageUrl: 'https://via.placeholder.com/400x300.png/34C759/FFFFFF?text=SHELTER',
      latitude: 35.6635,
      longitude: 139.6670,
    ),
    const Place(
      id: '3',
      name: 'Shinjuku LOFT',
      description: 'One of the most historic live houses in Tokyo, located in Shinjuku.',
      imageUrl: 'https://via.placeholder.com/400x300.png/FF9500/FFFFFF?text=LOFT',
      latitude: 35.6938,
      longitude: 139.7034,
    ),
    const Place(
      id: '4',
      name: 'Kichijoji Planet K',
      description: 'A popular spot for up-and-coming bands in the charming Kichijoji area.',
      imageUrl: 'https://via.placeholder.com/400x300.png/FF3B30/FFFFFF?text=Planet+K',
      latitude: 35.7031,
      longitude: 139.5800,
    ),
    const Place(
      id: '5',
      name: 'Ochanomizu Station Area',
      description: 'Famous for its many musical instrument shops, a must-visit for any band enthusiast.',
      imageUrl: 'https://via.placeholder.com/400x300.png/5856D6/FFFFFF?text=Ochanomizu',
      latitude: 35.6995,
      longitude: 139.7653,
    ),
  ];
}
