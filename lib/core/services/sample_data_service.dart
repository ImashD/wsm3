import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add sample farmer activities for chatbot context
  static Future<void> addSampleFarmerActivities() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final sampleActivities = [
      {
        'farmerId': uid,
        'activity': 'Planted 2 acres of Samba rice',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'planting',
        'crop': 'Samba',
        'area': '2 acres',
      },
      {
        'farmerId': uid,
        'activity': 'Applied fertilizer to Naadu crop',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'fertilizing',
        'crop': 'Naadu',
        'fertilizer': 'NPK 15-15-15',
      },
      {
        'farmerId': uid,
        'activity': 'Harvested 120kg of paddy',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'harvesting',
        'crop': 'Mixed',
        'quantity': '120kg',
      },
      {
        'farmerId': uid,
        'activity': 'Pest control spray applied',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'pest_control',
        'pesticide': 'Organic neem spray',
      },
    ];

    for (final activity in sampleActivities) {
      await _firestore.collection('farmer_activities').add(activity);
    }
  }

  /// Add sample market data for chatbot context
  static Future<void> addSampleMarketData() async {
    final marketData = [
      {
        'cropType': 'Samba',
        'price': 120.0,
        'unit': 'kg',
        'market': 'Colombo Central Market',
        'quality': 'Grade A',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'cropType': 'Naadu (Red)',
        'price': 100.0,
        'unit': 'kg',
        'market': 'Kandy Market',
        'quality': 'Grade B',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'cropType': 'Naadu (White)',
        'price': 110.0,
        'unit': 'kg',
        'market': 'Galle Market',
        'quality': 'Grade A',
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (final data in marketData) {
      await _firestore.collection('market_prices').add(data);
    }
  }

  /// Add sample weather data for chatbot context
  static Future<void> addSampleWeatherData() async {
    final weatherData = [
      {
        'location': 'Kurunegala',
        'temperature': 28.5,
        'humidity': 85,
        'rainfall': 'Moderate',
        'windSpeed': 12,
        'conditions': 'Partly Cloudy',
        'forecast': 'Light rain expected in evening',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'location': 'Anuradhapura',
        'temperature': 30.2,
        'humidity': 78,
        'rainfall': 'Light',
        'windSpeed': 8,
        'conditions': 'Sunny',
        'forecast': 'Clear skies for next 3 days',
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (final data in weatherData) {
      await _firestore.collection('weather_data').add(data);
    }
  }

  /// Initialize all sample data
  static Future<void> initializeSampleData() async {
    try {
      await addSampleFarmerActivities();
      await addSampleMarketData();
      await addSampleWeatherData();
      print('Sample data added successfully!');
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }
}