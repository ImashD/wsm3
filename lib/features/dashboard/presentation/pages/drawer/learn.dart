import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  final List<Map<String, String>> videos = const [
    {
      "title": "Paddy Farming & Cultivation 🌾",
      "url": "https://youtu.be/FW_bw9jdrlQ?si=bVQA8PilEJZJedtK",
      "id": "FW_bw9jdrlQ",
      "desc": "Learn step by step modern rice planting techniques.",
    },
    {
      "title": "Fertilizers & Crop Care 🧪",
      "url": "https://youtu.be/sa2sHxQfOBE?si=hlIcEz-og6UZn0Bp",
      "id": "sa2sHxQfOBE",
      "desc": "Tips on identifying nutrient deficiencies in rice plants.",
    },
    {
      "title": "Weather & Environment 🌦",
      "url": "https://youtu.be/mwr7yLWXsHc?si=pJcU76XPLAelkoEU",
      "id": "mwr7yLWXsHc",
      "desc": "How weather patterns affect paddy yield and growth.",
    },
    {
      "title": "Harvesting & Post-Harvest 🏭",
      "url": "https://youtu.be/cOOdoTIqaIE?si=VQJ-mHuzZmFV3O4C",
      "id": "cOOdoTIqaIE",
      "desc": "Best practices for harvesting and reducing losses.",
    },
    {
      "title": "Technology & Modern Farming 💡",
      "url": "https://youtu.be/kT1R7Hkps5M?si=uyaWA3t80h6usJvc",
      "id": "kT1R7Hkps5M",
      "desc": "Use of drones and AI in modern paddy farming.",
    },
    {
      "title": "Business & Market 📈",
      "url": "https://youtu.be/b-UbD3EiqrM?si=24T4zkuBge81-Rqo",
      "id": "b-UbD3EiqrM",
      "desc": "Understanding rice quality and marketing strategies.",
    },
  ];

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Learn from YouTube",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: videos.isEmpty
          ? const Center(
              child: Text(
                "📌 No learning videos available",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final thumbUrl =
                    "https://img.youtube.com/vi/${video["id"]}/0.jpg";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        thumbUrl,
                        width: 100,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.black54,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video["desc"] ?? "",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.teal,
                      size: 28,
                    ),
                    onTap: () => _launchUrl(video["url"]!),
                  ),
                );
              },
            ),
    );
  }
}
