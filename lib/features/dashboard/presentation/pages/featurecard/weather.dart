import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Replace with your OpenWeatherMap API key
  final String apiKey = "69c42806ae1bc77f6f0567ed02d2b91f";

  // Default city; can be changed via dropdown
  String selectedCity = "Colombo";
  bool _loading = true;
  Map<String, dynamic>? _weatherData;

  // List of districts/cities
  final List<String> cities = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() => _loading = true);
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=$apiKey&units=metric",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _loading = false;
        });
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching weather: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Forecast",
          style: TextStyle(color: Colors.teal),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _weatherData == null
          ? const Center(child: Text("Weather data not available"))
          : RefreshIndicator(
              onRefresh: fetchWeather,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // City Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_city, color: Colors.white),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedCity,
                          dropdownColor: Colors.teal.shade200,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          items: cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCity = value);
                              fetchWeather();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Weather Icon + Description
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "http://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png",
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _weatherData!['weather'][0]['description']
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Weather Details Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _weatherCard(
                          "Temperature",
                          "${_weatherData!['main']['temp']}°C",
                          Icons.thermostat,
                        ),
                        _weatherCard(
                          "Humidity",
                          "${_weatherData!['main']['humidity']}%",
                          Icons.water_drop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _weatherCard(
                          "Wind Speed",
                          "${_weatherData!['wind']['speed']} m/s",
                          Icons.air,
                        ),
                        _weatherCard(
                          "Feels Like",
                          "${_weatherData!['main']['feels_like']}°C",
                          Icons.device_thermostat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Small card widget for weather details
  Widget _weatherCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white70),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
