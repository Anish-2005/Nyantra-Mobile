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
