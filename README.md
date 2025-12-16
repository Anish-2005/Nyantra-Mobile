<div align="center">

# 🚀 Nyantra Mobile

### *Government Relief at Your Fingertips*

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Offline](https://img.shields.io/badge/Offline-First-success)]()

**Mobile app for SC/ST Act relief applications • Works offline • Voice-enabled • Multi-language**

</div>

---

## 💡 What It Does

```mermaid
graph LR
    A[👤 Apply] -->|📝| B[Track]
    B -->|💰| C[Receive]
    C -->|✅| D[Done]
    style A fill:#e3f2fd
    style D fill:#d4edda
```

Help beneficiaries **apply**, **track**, and **receive** government relief funds under the SC/ST Prevention of Atrocities Act. All from their phone. Even without internet.

### 🎯 Core Features

| Feature | What It Does |
|---------|--------------|
| 📱 **Applications** | Create & submit relief applications with voice input |
| 💰 **Payments** | Track 3-stage disbursement (25% → 50% → 25%) |
| 📊 **Dashboard** | Real-time overview of all applications & payments |
| 🗣️ **Voice Input** | Speak your forms (accessibility feature) |
| 🌐 **Offline Mode** | Full functionality without internet |
| 🔄 **Auto-Sync** | Data syncs automatically when connected |

---

## 🏗️ How It Works

```mermaid
graph TB
    subgraph Phone["📱 Your Phone"]
        UI[App Interface]
        DB[(Local Storage)]
    end
    
    subgraph Cloud["☁️ Cloud"]
        Firebase[(Firebase)]
    end
    
    UI <-->|Works Offline| DB
    DB <-.->|Auto Sync| Firebase
    
    style Phone fill:#e3f2fd
    style Cloud fill:#f3e5f5
```

**Offline-First Architecture**
- Create applications offline → Saved locally → Auto-syncs when online
- All data backed up to cloud
- Smart conflict resolution

---

## 🛠️ Built With

| Layer | Tech |
|-------|------|
| **Frontend** | Flutter 3.8+ (Dart) |
| **State** | Provider |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Database** | SQLite (offline) |
| **Features** | Voice-to-Text • PDF Generation • Multi-language |

---

## 📁 Project Structure

```
lib/
├── main.dart              # Entry point
└── src/
    ├── core/              # Providers, Services, Models
    ├── features/          # Auth, Dashboard, Applications
    │   ├── auth/
    │   ├── beneficiaries/
    │   ├── disbursements/
    │   └── grievances/
    └── components/        # Reusable UI widgets
```

---

## 🚀 Quick Start

```bash
# 1. Clone & navigate
git clone <repo-url>
cd Nyantra-Mobile

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run
```

**Firebase Setup**: Add `google-services.json` to `android/app/` ([Get it here](https://console.firebase.google.com))

---

## 🎨 Key Features Visualized

### Disbursement Flow
```
Application Approved
        ↓
    Stage 1: 25% ✅ (Immediate)
        ↓
    Stage 2: 50% ⏳ (Processing)
        ↓
    Stage 3: 25% ⏳ (Final)
```

### Offline Sync
```mermaid
sequenceDiagram
    User->>App: Create Application
    App->>SQLite: Save Locally ✅
    Note over App: Internet comes back
    App->>Firebase: Sync ☁️
```

---

## 🔐 Security

✅ Firebase Authentication  
✅ Role-based access control  
✅ Encrypted local storage  
✅ Secure cloud backup

## 🌍 Languages

🇬🇧 English • 🇮🇳 हिंदी

---

<div align="center">

**Built with ❤️ for Social Justice**

*Making relief accessible to everyone, everywhere*

