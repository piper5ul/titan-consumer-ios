# Titan Wallet - Consumer iOS App

**Version:** 1.0.0
**Platform:** iOS 14.0+
**Language:** Swift 5.0+
**Architecture:** UIKit + Storyboards

---

## 🎯 Overview

Titan Wallet Consumer iOS app is a feature-complete mobile wallet for real-time payments, built on top of Titan's backend microservices platform.

**Forked from:** Solid.fi Banking Platform (42,000 LOC production-proven code)
**Adapted for:** Titan Wallet ecosystem with @handle payments and real-time settlements

## Tooling
- iOS 14.0 +
- Xcode 14 +
- Swift 5.0 +
- CocoaPods
- Packages

## API Reference
- All API endpoints are added in EndpointType.swift and EndpointItem.swift files
- API code is added in individual view model class eg., KYBViewModel.swift
- App level common API calls are made from APIBaseVC.swift

## Features 
- Authentication (Auth0)
- Person (KYC)
- Business (KYB)
- Bank Accounts
- Pull Funds
- Contacts
- Send
- Receive
- Cards
- Transactions
- In-app provisioning (Apple wallet)

## Dependencies
- Analytics
- Alamofire
- Firebase/Crashlytics
- Firebase/Analytics
- GooglePlace
- lottie-ios
- Plaid
- RNCryptor
- SwiftKeychainWrapper
- SDWebImageSVGCoder
- SDWebImage
- SkeletonView
- VGSShowSDK
- VGSCollectSDK
- MercariQRScanner


Doc reference :
- API Doc for reference : https://www.solidfi.com/dev
- Figma Design file for reference : https://www.figma.com/file/CUEcwPWWrZfHuAGPoWBNRg/Generic-Apps?node-id=2815%3A140

## Getting started

### 1. Required Keys:

In order to start building and running the Solid wallet project, you'll need certain configuration keys set up.

#### 1.1 Auth0 Client ID (Required)

For login we use Auth0's passwordless service. For each application to work we need to setup configuration in Auth0 as well as in client app. Auth0 client ID is a key used to connect client apps to Solid's backend APIs and Auth0. The wallet apps use a token based authentication scheme as described in [Solid User Auth](https://www.solidfi.com/dev#authentication). The Solid User Auth process results in an access token that allows our apps to directly connect with Solid's API(s). This is separate from the API key model which allows customers to make secure machine-to-machine calls without an access token. The Auth Client ID can be generated in the [Soild Dashboard](https://dashboard.solidfi.com) under the developer section. Then set it under `env -> auth0ClientId` in the file `AppMetaData.json` file at path `/Solid/Solid/Source/Classes/Utilities/App Utils`. For the test environment set the Auth Client ID (auth0ClientId) variable in prodtest and for live set under prod. Contact Solid's support team in case you need help in setting up Auth0 Client Id.

#### 1.2 Auth0 Audience and Auth0 Domain (Required)

Auth0 Audience and Domain are the keys used by Auth0 to identify the correct application to manage users accordingly. These values are added under `env -> auth0Audience` and `env -> auth0Domain` in the file `AppMetaData.json` file at path `/Solid/Solid/Source/Classes/Utilities/App Utils`.

#### 1.3 VGS Vault ID (Optional)

Solid uses Very Good Security (VGS) for PCI compliance and to help keep our customers out of scope. VGS tokenizes PCI specific card data so that neither Solid nor the customer have to store card numbers or cvvs. The VGS vault ID can be requested via a Solid Dashboard Help Desk ticket. Once obtained the Vault ID should be set under `VGS` in the `Config.swift` file at path `/Solid/Source/Classes/Utilities/Constants/Config.swift`.

Note: If the Vault ID(s) are omitted cards will not be shown unredacted.

#### 1.4 Google Places Key (Optional)

Solid uses Google Places to show location details in the wallet apps. For more details on obtaining a Google Maps Key please refer to this [doc](https://developers.google.com/maps/documentation/javascript/get-api-key). The Google Maps Key should be set under `GooglePlaces` in the `Config.swift` file at path `/Solid/Source/Classes/Utilities/Constants/Config.swift`.

Note: If the Google Places Key is omitted then location details will not be shown. You will need to enter address manually in the UI.
For ex.   ` "address": {
       "addressType": "mailing",
       "line1": "123 Main St",
       "line2": "",
       "city": "New York",
       "state": "NY",
       "country": "US",
       "postalCode": "10001"
   }`

#### 1.5 Segment(Optional)

The Solid wallet apps use [Segment](https://segment.com/) for analytics. If you want to enable analytics support then update the Segment Key under env -> segmentKey` in the file `AppMetaData.json` file at path `/Solid/Solid/Source/Classes/Utilities/App Utils`.

### 2. In-app provisioning (Apple wallet):
Please contact Apple Pay Entitlements <applepayentitlements@apple.com> from the Apple developer account owner email ID for enabling push provisioning entitlements.

Note: you can disable/remove In-app provisioning by following steps:
- Remove `Solid.entitlements` from project
- Remove `Wallet` from `Capabilites` section in xcode
- Comment `checkEligibility()` from `viewWillAppear()` in `CardInfoVC.swift` OR remove code related to `Passkit`

## Install and run CocoaPods

Installing CocoaPods at https://cocoapods.org/

In the `Solid/` directory run `pod install`

## Open workspace and run in Simulator

1. Launch `Xcode` and open the workspace `Solid/Solid.xcworkspace`
1. Run in Simulator

## Testing
For the ease of development, Solid Banking Platform offers you two modes:

- Test: Test credentials and real-life like data. Requests made to the Test environment will never hit banking or payments or identity verification networks. These will never affect live data.

- Live: Real credentials and real data. Requests made to the Live environment will hit Live environments of banking or payments or identity verification networks. These will hit live data.
