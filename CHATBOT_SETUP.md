# 🤖 AI Chatbot Integration Guide

## 📋 **Implementation Overview**

Your AI chatbot has been successfully integrated into the farmer dashboard with the following features:

### ✨ **Features Implemented**

- 🤖 **Context-Aware AI**: Uses farmer's data from Firebase for personalized responses
- 💬 **Real-time Chat**: Instant messaging with AI assistant
- 📱 **Floating Interface**: Non-intrusive floating chatbot button
- 💾 **Chat History**: Persistent conversation storage in Firestore
- 🌾 **Agricultural Focus**: Specialized prompts for farming advice

---

## 🛠️ **Setup Instructions**

### **Step 1: Install Dependencies**

```bash
flutter pub get
```

### **Step 2: Get Gemini AI API Key (FREE)**

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### **Step 3: Configure API Key**

Open `lib/core/services/chatbot_service.dart` and replace:

```dart
static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

With your actual API key:

```dart
static const String _geminiApiKey = 'AIzaSy...your_actual_key';
```

### **Step 4: Test the Implementation**

1. Run your app: `flutter run`
2. Navigate to farmer dashboard
3. Look for the floating chat button (bottom-right)
4. Tap to open the chatbot and start chatting!

---

## 🏗️ **Architecture Details**

### **Database Collections Created**

```text
📁 chat_history/
  └── {userId}/
      └── messages/
          ├── message1 (user message)
          ├── message2 (AI response)
          └── ...

📁 farmer_activities/ (for context)
  ├── activity1 (planting, harvesting, etc.)
  └── ...

📁 market_prices/ (for context)
📁 weather_data/ (for context)
```

### **AI Context Sources**

The chatbot pulls data from:

- ✅ **Farmer Profile**: Name, farm location, crop types, farm size
- ✅ **User Data**: Registration details, contact info
- ✅ **Recent Activities**: Farming activities (if implemented)
- ✅ **Market Data**: Crop prices (if available)
- ✅ **Weather Info**: Local weather conditions (if available)

---

## 💡 **Sample Questions to Test**

Try asking the chatbot:

- "What's the best time to plant Samba rice?"
- "How can I improve my crop yield?"
- "Tell me about pest control for paddy"
- "What fertilizers should I use?"
- "How do I register as a driver on this platform?"
- "Show me my farm details"

---

## 🔧 **Customization Options**

### **1. Change AI Model**

```dart
// In chatbot_service.dart, replace Gemini with OpenAI:
// import 'package:dart_openai/dart_openai.dart';

// Then use OpenAI API instead of Gemini
```

### **2. Modify Chatbot Appearance**

Edit `lib/features/dashboard/presentation/widgets/chatbot_widget.dart`:

- Change colors, fonts, sizes
- Add custom animations
- Modify chat bubble styles

### **3. Enhance Context Data**

Add more data sources in `ChatbotService._getFarmerContext()`:

```dart
// Add crop prices
final priceDoc = await _firestore.collection('market_prices').get();
context['market_prices'] = priceDoc.docs.map((doc) => doc.data()).toList();

// Add weather data
final weatherDoc = await _firestore.collection('weather_data').get();
context['weather'] = weatherDoc.docs.map((doc) => doc.data()).toList();
```

### **4. Add Voice Input/Output**

Consider adding:

- `speech_to_text` package for voice input
- `flutter_tts` package for voice responses

---

## 🚀 **Next Steps & Enhancements**

### **Phase 2 Features**

1. **Voice Chat**: Add speech-to-text and text-to-speech
2. **Image Analysis**: Let farmers upload crop photos for disease detection
3. **Weather Integration**: Real-time weather API integration
4. **Market Prices**: Live crop price feeds
5. **Multilingual**: Support for Sinhala and Tamil languages
6. **Offline Mode**: Basic responses when internet is unavailable

### **Advanced Features**

1. **Crop Disease Detection**: Image-based disease identification
2. **Yield Prediction**: AI-based harvest forecasting
3. **Smart Irrigation**: IoT sensor integration advice
4. **Market Insights**: Price trend analysis and recommendations

---

## 🐛 **Troubleshooting**

### **Common Issues**

## API Key Errors

```text
Error: API key not valid
```

## Solution

Ensure your Gemini API key is correctly set in `chatbot_service.dart`

## Firebase Permission Errors

```text
Error: Permission denied
```

## Solution - Firebase Rules

Update Firestore security rules to allow authenticated users to read/write chat data

## Build Errors

```text
Error: Package not found
```

## Solution - Clean Build

Run `flutter clean` then `flutter pub get`

### **Firebase Rules Update**

Add to your `firestore.rules`:

```javascript
// Allow authenticated users to access their chat history
match /chat_history/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  
  match /messages/{messageId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
}

// Allow all users to read market data and weather (for context)
match /market_prices/{docId} {
  allow read: if true;
}

match /weather_data/{docId} {
  allow read: if true;
}

match /farmer_activities/{docId} {
  allow read, write: if request.auth != null;
}
```

---

## 💰 **Cost Considerations**

### **Gemini AI (Recommended - FREE)**

- ✅ **Free Tier**: 60 requests per minute
- ✅ **Perfect for Development**: No cost during testing
- ✅ **Production Ready**: Upgrade when needed

### **OpenAI Alternative**

- 💰 **Paid Service**: ~$0.002 per 1K tokens
- ⚡ **Higher Quality**: More sophisticated responses
- 🔧 **Easy Switch**: Same architecture, different API

---

## 📊 **Monitoring & Analytics**

Track chatbot usage:

```dart
// Add to chatbot_service.dart
await _firestore.collection('chatbot_analytics').add({
  'userId': uid,
  'question': userMessage,
  'response_length': response.length,
  'timestamp': FieldValue.serverTimestamp(),
});
```

---

## 🎯 **Success Metrics**

Monitor these KPIs:

- 📈 **User Engagement**: Daily active chatbot users
- ⏱️ **Response Time**: Average AI response time
- 👍 **User Satisfaction**: Chat ratings/feedback
- 🔄 **Retention**: Repeat usage patterns
- 🎯 **Query Success**: Questions answered successfully

---

Your AI chatbot is now ready to help farmers with agricultural advice, platform guidance, and personalized assistance! 🌾🤖

For support or advanced customizations, refer to the code comments or create additional helper services.
