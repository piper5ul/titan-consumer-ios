# Titan Wallet - Consumer iOS App

**Version:** 1.0.0
**Platform:** iOS 14.0+
**Language:** Swift 5.0+
**Architecture:** UIKit + Storyboards

---

## 🎯 Overview

Titan Wallet Consumer iOS app is a feature-complete mobile wallet for real-time payments, built on top of Titan's backend microservices platform.

**Base Code:** Production-proven banking app (42,000 LOC)
**Key Features:** @handle payments, real-time settlements, ACH transfers, KYC/KYB verification

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd titan-consumer-ios/TitanConsumer
pod install
```

### 2. Open Workspace

```bash
open TitanConsumer.xcworkspace
```

### 3. Run on Simulator

Press `Cmd+R` or click the ▶️ button in Xcode.

The app will connect to Titan backend services on `localhost:8001-8006` in test mode.

---

## ⚙️ Configuration

All configuration is in `TitanConsumer/Solid/Source/Classes/Utilities/App Utils/AppMetaData.json`

### Auth0 Credentials (Already Configured)

```json
{
  "env": {
    "prod": {
      "auth0ClientId": "5pjTAHK7cjXIdFxmrPnL50LKcNbu2uys",
      "auth0Domain": "dev-gpkn7n5wg1qsbl4g.us.auth0.com",
      "auth0Audience": "https://api.titanwallet.com"
    },
    "prodtest": {
      "auth0ClientId": "5pjTAHK7cjXIdFxmrPnL50LKcNbu2uys",
      "auth0Domain": "dev-gpkn7n5wg1qsbl4g.us.auth0.com",
      "auth0Audience": "https://api-test.titanwallet.com"
    }
  }
}
```

### Optional: Google Places API Key

For address autocomplete during KYC, add your key to `Config.swift`:

```swift
// Path: TitanConsumer/Solid/Source/Classes/Utilities/Constants/Config.swift
struct Config {
    static let GooglePlaces = "YOUR_GOOGLE_PLACES_API_KEY"
}
```

---

## 🏗️ Architecture

### Microservices Integration

The app routes API calls to different Titan services based on endpoint type:

| Service | Port (Dev) | Production URL | Purpose |
|---------|-----------|----------------|---------|
| Handle Resolution | 8001 | hrs.titanwallet.com | @handle lookup |
| Payment Router | 8002 | payments.titanwallet.com | Payment processing |
| ACH Service | 8003 | ach.titanwallet.com | Plaid/ACH integration |
| Auth Service | 8004 | auth.titanwallet.com | User authentication |
| User Management | 8006 | users.titanwallet.com | KYC/KYB, users, contacts |

**See:** `EndpointItem.swift` for routing logic (line 94+)

---

## 📱 Features

### Consumer Features
- ✅ **@handle Payments** - Send money via @alice instead of account numbers
- ✅ **Real-time Transfers** - Instant settlement via RTP
- ✅ **Bank Account Linking** - Plaid integration for ACH
- ✅ **Pull Funds** - Transfer from external bank accounts
- ✅ **Send Money** - ACH, Wire, Intrabank transfers
- ✅ **Contacts** - Save recipients for quick payments
- ✅ **Transaction History** - View all payment activity
- ✅ **KYC Verification** - Identity verification flow
- ✅ **Business Accounts** - KYB for business users
- ✅ **Cards** - Virtual/physical debit cards (future)
- ✅ **Apple Wallet** - Add card to Apple Pay (future)

### Disabled for Consumer App
- ❌ Check deposits
- ❌ Visa card sends
- ❌ Physical card mailing

---

## 🧪 Testing

### Test Modes

Switch between environments in AppMetaData.json:

**Test Mode** (Default):
- Uses `localhost:8001-8006` for Titan services
- Safe for development - no real money

**Live Mode**:
- Uses production Titan URLs
- Real transactions with real money

### Running Tests

```bash
cd titan-consumer-ios/TitanConsumer
# Run unit tests
xcodebuild test -workspace TitanConsumer.xcworkspace -scheme Solid -destination 'platform=iOS Simulator,name=iPhone 14'
```

---

## 📂 Project Structure

```
titan-consumer-ios/
├── TitanConsumer/                    # Main workspace folder
│   ├── TitanConsumer.xcworkspace    # Open this in Xcode
│   ├── Solid.xcodeproj              # Xcode project (internal)
│   ├── Podfile                      # CocoaPods dependencies
│   └── Solid/                       # Source code
│       ├── Source/
│       │   ├── Classes/
│       │   │   ├── Networking/
│       │   │   │   ├── EndpointItem.swift    # Titan API routing
│       │   │   │   └── EndpointType.swift
│       │   │   ├── Utilities/
│       │   │   │   └── App Utils/
│       │   │   │       └── AppMetaData.json  # App configuration
│       │   │   ├── ViewControllers/
│       │   │   └── ViewModels/
│       │   └── Resources/
│       └── Storyboards/
└── README.md
```

---

## 🔧 Development

### Building

```bash
cd titan-consumer-ios/TitanConsumer
pod install
open TitanConsumer.xcworkspace

# Build: Cmd+B
# Run: Cmd+R
# Test: Cmd+U
```

### Running Titan Backend (Required for Testing)

```bash
cd /Users/pushkar/Downloads/rtpayments/titan-backend-services
docker-compose up -d

# Services will be available on:
# - HRS: localhost:8001
# - Payment Router: localhost:8002
# - ACH Service: localhost:8003
# - Auth Service: localhost:8004
# - User Management: localhost:8006
```

### Debugging

- Set breakpoints in ViewControllers or ViewModels
- Check network calls in `APIManager.swift`
- View logs in Xcode console

---

## 📚 Key Files

| File | Purpose |
|------|---------|
| `AppMetaData.json` | Auth0 config, feature flags, branding |
| `EndpointItem.swift` | API routing to Titan microservices |
| `APIManager.swift` | HTTP client using Alamofire |
| `Config.swift` | API keys (Google Places, etc.) |
| `Podfile` | Dependency management |

---

## 🐛 Troubleshooting

### "CocoaPods not found"
```bash
sudo gem install cocoapods
```

### "Build failed - Signing error"
In Xcode:
1. Select project in navigator
2. Select target
3. Signing & Capabilities tab
4. Change Team to your Apple ID

### "Can't connect to backend"
Make sure Titan services are running:
```bash
docker ps | grep titan
# Should show 8 services running
```

### "Auth0 login not working"
1. Check Auth0 callback URL is configured in Auth0 dashboard:
   - `com.titanwallet.consumer://callback`
2. Verify credentials in AppMetaData.json

---

## 🚢 Deployment

### TestFlight

1. Archive app (Product → Archive)
2. Upload to App Store Connect
3. Submit for TestFlight review

### App Store

1. Update version in Xcode
2. Create release in App Store Connect
3. Submit for review

---

## 📖 Additional Documentation

- **API Integration Guide:** `/docs/API_INTEGRATION_GUIDE.md`
- **Mobile Fork Strategy:** `/docs/MOBILE_APP_FORK_STRATEGY.md`
- **Rebranding Cleanup:** `/docs/REBRANDING_CLEANUP_GUIDE.md`

---

**Titan Wallet** - The future of payments is instant ⚡
