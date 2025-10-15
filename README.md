# 🤖 AI-Enhanced WorkForce Management System

An intelligent Flutter application designed to connect farmers, drivers, and laborers in an agricultural ecosystem with **AI-powered chatbot assistance**.

## ✨ **New Features - AI Chatbot Integration**

### 🎯 **Context-Aware AI Assistant**

- **Personalized Responses**: Uses farmer's profile data for tailored agricultural advice
- **Real-time Chat**: Instant messaging with AI assistant in farmer dashboard
- **Smart Recommendations**: Crop-specific advice based on user's farming details
- **Platform Guidance**: Help with app features and navigation
- **Persistent Chat History**: Conversations stored in Firebase Firestore

### 🌾 **Agricultural Intelligence**

- **Crop Management**: Planting, fertilizing, and harvesting advice
- **Weather Insights**: Contextual weather-based recommendations
- **Market Information**: Price trends and market guidance
- **Pest Control**: Disease identification and treatment suggestions

## 🚀 **Getting Started with AI Chatbot**

### **Prerequisites**

1. **Flutter SDK** (3.8.1 or higher)
2. **Firebase Project** (already configured)
3. **Gemini AI API Key** (FREE from Google AI Studio)

### **Quick Setup**

1. **Get your free API key**:
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create your free Gemini API key

2. **Configure the chatbot**:

   ```dart
   // In lib/core/services/chatbot_service.dart
   static const String _geminiApiKey = 'YOUR_API_KEY_HERE';
   ```

3. **Run the app**:

   ```bash
   flutter pub get
   flutter run
   ```

4. **Test the chatbot**:
   - Navigate to farmer dashboard
   - Look for the floating chat button (🤖)
   - Start chatting with your AI assistant!

## 📱 **Core Features**

### **Multi-Role Authentication System**

- **Farmers**: Profile management with QR code generation
- **Drivers**: Vehicle and license management  
- **Laborers**: Skill-based registration and job matching

### **Smart Dashboard Features**

- **Market Rate Tracking**: Real-time crop pricing
- **Service Requests**: Connect with drivers and laborers
- **Cultivation Management**: Track farming activities
- **Weather Integration**: Location-based weather updates
- **🆕 AI Assistant**: Context-aware farming advice

### **Modern UI/UX**

- Material Design 3 with Google Fonts
- Animated onboarding experience
- Responsive design for all devices
- Dark/light theme support

## 🏗️ **Technical Architecture**

### **Frontend**

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: Material Design 3

### **Backend & AI**

- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **AI Engine**: Google Gemini Pro (FREE tier)
- **Chat Storage**: Real-time Firestore collections

### **Key Dependencies**

```yaml
dependencies:
  # Core Flutter & Firebase
  firebase_core: ^4.1.1
  firebase_auth: ^6.1.0
  cloud_firestore: ^6.0.2
  
  # AI Chatbot
  google_generative_ai: ^0.4.3  # Gemini AI
  dart_openai: ^5.1.0           # Optional OpenAI
  uuid: ^4.3.3                  # Message IDs
  
  # UI & Navigation
  go_router: ^13.1.0
  google_fonts: ^6.1.0
  provider: ^6.1.1
```

## 🤖 **AI Chatbot Features**

### **Context Sources**

The AI assistant pulls information from:

- ✅ **Farmer Profile**: Name, location, crops, farm size
- ✅ **User Activities**: Planting, harvesting, fertilizing records
- ✅ **Market Data**: Current crop prices and trends
- ✅ **Weather Data**: Local weather conditions
- ✅ **Platform Features**: App navigation and feature guidance

### **Sample Questions**

Try asking your AI assistant:

- "What's the best time to plant Samba rice?"
- "How can I improve my paddy yield?"
- "Tell me about pest control options"
- "What fertilizers work best for my crop type?"
- "How do I request a driver on this platform?"
- "Show me my farm details"

### **Chat Features**

- **Real-time Messaging**: Instant responses from AI
- **Message History**: Persistent conversation storage
- **Floating Interface**: Non-intrusive chat bubble
- **Context Awareness**: Responses based on your farm data
- **Multi-language Ready**: Prepared for Sinhala/Tamil support

## 📊 **Database Schema**

### **Enhanced Collections**

```
📁 users/                    # User authentication data
📁 farmers/                  # Farmer profiles with QR data
📁 chat_history/            # 🆕 AI chat conversations
  └── {userId}/messages/    # User-specific chat history
📁 farmer_activities/       # 🆕 Farming activity logs
📁 market_prices/          # 🆕 Crop pricing data
📁 weather_data/           # 🆕 Weather information
```

## 🔐 **Security & Privacy**

### **Data Protection**

- **Encrypted Communication**: All AI conversations encrypted
- **User-specific Data**: Chat history isolated per user
- **Firebase Rules**: Secure access control implemented
- **API Key Security**: Environment-based configuration

### **Firestore Security Rules**

```javascript
// Chat history access control
match /chat_history/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## 🎯 **Development Roadmap**

### **Phase 1: ✅ Completed**

- Multi-role authentication system
- Firebase integration
- QR code generation
- Basic dashboard features
- **🆕 AI chatbot integration**

### **Phase 2: 🚧 In Progress**

- Voice chat capabilities
- Image-based crop disease detection
- Real-time weather API integration
- Market price automation
- Multilingual support (Sinhala/Tamil)

### **Phase 3: 📋 Planned**

- IoT sensor integration
- Yield prediction algorithms
- Advanced analytics dashboard
- Social features for farmers
- Offline mode support

## 🛠️ **Development Setup**

### **Environment Setup**

```bash
# Clone the repository
git clone <repository-url>
cd AI-chatbot

# Install dependencies
flutter pub get

# Configure API keys (see CHATBOT_SETUP.md)
# Add your Gemini API key to chatbot_service.dart

# Run the application
flutter run
```

### **Testing the AI Features**

1. **Register as a farmer** with complete profile
2. **Navigate to farmer dashboard**
3. **Tap the floating chat button** (🤖)
4. **Start conversations** with farming questions
5. **Check chat history** persistence

## 📖 **Documentation**

- **[Chatbot Setup Guide](CHATBOT_SETUP.md)**: Detailed AI integration instructions
- **[API Documentation](docs/api.md)**: Firebase and AI service integration
- **[Contributing Guidelines](CONTRIBUTING.md)**: Development contribution guide

## 🤝 **Contributing**

We welcome contributions to enhance the AI capabilities and overall functionality:

1. **Fork the repository**
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit changes** (`git commit -m 'Add amazing feature'`)
4. **Push to branch** (`git push origin feature/amazing-feature`)
5. **Open Pull Request**

### **AI Enhancement Ideas**

- Voice input/output for chatbot
- Image recognition for crop diseases
- Predictive analytics for yield
- Weather-based recommendations
- Market trend analysis

## 📜 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 **Team**

- **Frontend Development**: Flutter experts
- **AI Integration**: Machine learning specialists  
- **Backend**: Firebase architects
- **UI/UX**: Design professionals

## 📞 **Support**

For technical support or AI chatbot issues:

- **Email**: <support@workforce-app.com>
- **Documentation**: [CHATBOT_SETUP.md](CHATBOT_SETUP.md)
- **Issues**: GitHub Issues tab

---

**🌾 Empowering farmers with AI-driven agricultural intelligence! 🤖**
