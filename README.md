# Nyantara Mobile — Direct Benefit Transfer Management System (Mobile)

<div align="center">
  <img src="/assets/images/Logo-Light.png" alt="Nyantara Mobile Logo" width="120" height="120"/>

  **Nyantara Mobile**

  *Empowering Social Justice — Mobile First*
</div>

---

## 📱 Overview

Nyantara Mobile is the beneficiary-facing application of the **Nyantara DBT Management System**, built to streamline the application, verification, and disbursement process for victims seeking relief under the SC/ST (Prevention of Atrocities) Act, 1989.

The app is designed to work in low-connectivity rural environments, offering **offline-first capability**, **real-time updates**, **document uploads**, **notifications**, and **end-to-end secure workflows**.

---

## ✨ Key Features

### 📝 Application Submission
- Guided multi-step application form  
- Document capture via camera or gallery  
- Speech-to-text input for accessibility  
- Auto-save drafts & offline form completion  
- Local validation and smart suggestions  

### 📊 Status & Disbursement Tracking
- Real-time application updates  
- Visual disbursement timeline:  
  **Initial 25% → Interim 50% → Final 25%**  
- Payment receipt download  
- Push notifications and email alerts  

### 🌐 User Experience
- Material Design 3 UI  
- Dark/Light theme  
- Fully responsive on all screen sizes  
- English & Hindi support (extensible for more languages)  
- Screen-reader and high-contrast modes  

### 🔐 Security & Identity
- Firebase Authentication  
- Role-based access (Beneficiary / Officer)  
- Encrypted document storage  
- Aadhaar/DigiLocker verification ready  

### 🔄 Offline Support
- Offline form saving  
- SQLite-powered local cache  
- Automatic background sync  
- Conflict resolution with Firestore  

### 🛠 Additional Capabilities
- Grievance submission  
- Notifications for deadlines & payment events  
- PDF export  
- Crash reporting & analytics via Firebase  

---

## 🛠 Technology Stack

### **Mobile**
| Component | Technology |
|----------|------------|
| Framework | Flutter 3.8+ |
| Language | Dart 3.8+ |
| State Management | Provider |
| Local DB | SQLite (sqflite) |
| Authentication | Firebase Auth |
| Backend | Firestore + Cloud Functions |
| File Storage | Firebase Storage |
| Routing | go_router |
| Animations | flutter_animate |
| Speech Input | speech_to_text |
| PDF Creation | pdf + printing |

### **Dev Tools**
- Git & GitHub  
- CI/CD with GitHub Actions  
- Flutter Lints  
- Firebase Crashlytics  
- Firebase Analytics  

### Mobile Application
```bash
flutter pub get      # Install dependencies
flutter run          # Run on device/emulator
flutter build apk    # Build Android APK
flutter build ios    # Build iOS app
```

---

## 🎨 Design System

- **Themes**: Light/Dark mode with CSS custom properties
- **Typography**: System fonts with fallbacks
- **Color Palette**: Accessible color combinations
- **Components**: Glassmorphism effects and smooth animations
- **Responsive**: Mobile-first design with breakpoint system

---

## 🌐 Internationalization

- **Languages**: English (en) and Hindi (hi)
- **Implementation**: JSON-based translations with React Context
- **Coverage**: Complete UI translation with RTL support ready
- **Management**: Automated scripts for key extraction and validation

---

## 🔒 Security & Privacy

- **Authentication**: Firebase Auth with email/password and Google sign-in
- **Authorization**: Role-based access control (Admin/User)
- **Data Encryption**: Firebase's built-in encryption at rest
- **API Security**: Server-side validation and input sanitization
- **Privacy**: GDPR-compliant data handling practices

---

## 📈 Performance

- **Web Vitals**: Optimized for Core Web Vitals
- **Bundle Size**: Tree-shaken imports and lazy loading
- **Caching**: Intelligent caching strategies
- **Mobile**: Optimized for low-bandwidth environments
- **PWA Ready**: Service worker and offline capabilities

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow TypeScript strict mode
- Use ESLint and Prettier for code formatting
- Write tests for new features
- Update documentation for API changes
- Ensure accessibility compliance

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built for disaster relief management under PM-CARES initiatives
- Inspired by real-world humanitarian aid workflows
- Thanks to the open-source community for the amazing tools and libraries

---

## 📞 Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Check the documentation in `/docs` folder

---

*Built with ❤️ for efficient disaster relief operations*

