# AutoDealers India — Multi-Vendor Car Dealer Lead Generation SaaS Platform

**"List Your Cars & Get More Customer Enquiries"**

AutoDealers India is a production-ready, multi-vendor automotive marketplace & Lead Generation SaaS platform built with **Flutter** (Web, Mobile, Desktop) and a robust **Firebase Architecture** (Authentication, Cloud Firestore, Cloud Storage), designed specifically for the Indian automotive market with **₹ (INR)** currency.

---

## 1. Core Value Proposition & Positioning

Rather than functioning solely as a static car directory, the platform is engineered as a **SaaS Lead Generation Machine**:
* **Dealers**: List vehicles, receive real-time customer enquiries, direct WhatsApp chats, and direct phone calls with complete CRM pipeline tracking.
* **Buyers**: Search and filter 50+ certified pre-owned cars from verified dealerships, view detailed specs, and contact dealers directly with zero commissions.
* **Super Admin**: Manage dealers through a 4-stage verification lifecycle (`Pending` -> `Submitted` -> `Approved` -> `Verified`), moderate car inventory, configure pricing plans, manage subscriptions/trials, and monitor platform revenue.

---

## 2. Key Features Implemented

### 🌟 7-Day Free Trial System
* Every newly registered dealership automatically receives a **7-Day Free Trial** (configurable in Admin Settings).
* During trial: Full dealer profile, up to 10 car listings, direct WhatsApp leads, phone calls, and CRM tracking.
* Real-time countdown banner in the Dealer Dashboard: *"Your free trial ends in X days"* with a *"Choose a Plan"* CTA.

### 🛡️ Dealer Verification Pipeline
* 4-Stage Lifecycle: `Pending` → `Submitted` → `Approved` → `Verified`.
* Public **"Verified Dealer"** badge displays strictly when `verificationStatus == 'verified'`.
* Admin moderation actions: **Approve**, **Reject**, **Verify**, **Suspend**, **Reactivate**.

### 📊 Lead Generation CRM & Dealer ROI Dashboard
* **Lead Overview** at top of Dealer Dashboard:
  * Total Enquiries, New, Contacted, Interested, Converted, Closed.
  * Direct contact metrics: Car Views, Dealer Profile Views, WhatsApp Clicks, Phone Calls.
* **Dealer Performance & ROI Metrics**:
  * **Enquiry Conversion Rate**: `(Enquiries / Car Views) * 100` (safe division, zero protection).
  * **Lead Closing Rate**: `(Converted / Enquiries) * 100` (safe division, zero protection).
* **Interactive CRM Pipeline**:
  * Status transitions: `New` → `Contacted` → `Interested` → `Converted` → `Closed`.
  * One-click **"Call Customer"** (`tel:`) and **"WhatsApp Customer"** (`wa.me`).
  * Lead source attribution: *Car Detail Page*, *Dealer Profile*, *WhatsApp*, *Phone*, *Enquiry Form*.

### 💎 Configurable Subscription Plans & Limit Enforcement
* Configurable from Super Admin (no hard-coded prices or limits):
  * **Starter**: ₹499/month (10 cars, verified profile, WhatsApp leads)
  * **Business**: ₹999/month (30 cars, verified priority, CRM, analytics) — *Visually Highlighted as Recommended Plan*
  * **Pro**: ₹1,999/month (100 cars, featured placement, priority leads, advanced analytics)
* **Listing Limit Enforcement**:
  * Server-side/business logic checks current stock vs. plan limits before publishing new vehicles.
  * Expired subscription preserves data but prevents adding new listings above limit.

### 💳 Modular Razorpay Payment Architecture
* Modular payment abstraction (`IPaymentGateway`, `RazorpayService`) ready for test & live API keys.
* Supports simulated order creation, webhook callback stubs, and Super Admin manual activation/extension.

### 🚗 Realistic Indian Automotive Demo Data
* **10 Indian Dealerships** clearly tagged as `Demo Dealer` across Muktsar, Delhi NCR, Mumbai, Chandigarh, Bengaluru, Pune, Hyderabad, Ahmedabad, Chennai, and Jaipur.
* **50 Realistic Indian Cars** (Swift, Creta, Nexon, Thar 4x4, Fortuner Legender, Seltos, City, XUV700, Baleno, Harrier, etc.) with high-resolution photos, ₹ Lakhs pricing, fuel types (Petrol, Diesel, CNG, Electric, Hybrid).

---

## 3. Project Structure

```
cardealers/
├── firestore.rules                         # Multi-tenant isolation & security rules
├── pubspec.yaml                            # Flutter dependencies & assets
├── lib/
│   ├── main.dart                           # Entrypoint with clean URLs & MultiProvider
│   ├── firebase_options.dart               # FlutterFire options configuration
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart             # Automotive brand color palette
│   │   │   ├── app_constants.dart          # Indian brands, cities, fuels, body types
│   │   │   └── app_routes.dart             # GoRouter URL definitions
│   │   ├── theme/
│   │   │   └── app_theme.dart              # Modern SaaS light theme styling
│   │   ├── utils/
│   │   │   ├── formatters.dart             # ₹ Currency (Lakhs/Thousands), dates
│   │   │   └── responsive.dart             # Desktop, Tablet, Mobile breakpoints
│   │   └── router/
│   │       └── app_router.dart             # Navigation routing & deep-linking
│   ├── models/
│   │   ├── user_model.dart                 # Super Admin & Dealer user model
│   │   ├── dealer_model.dart               # Dealership profile, verification & trial
│   │   ├── car_model.dart                  # Vehicle specs, featured metadata & counters
│   │   ├── enquiry_model.dart              # CRM lead model & attribution
│   │   ├── subscription_plan_model.dart    # Configurable SaaS plans
│   │   ├── analytics_model.dart            # Analytics events & conversion math
│   │   └── admin_settings_model.dart       # Trial duration & approval rules
│   ├── data/
│   │   ├── seed_data.dart                  # 10 Indian dealers, 50 cars, sample leads
│   │   └── app_data_store.dart             # Reactive data store with local fallback
│   ├── services/
│   │   ├── firebase_service.dart           # Safe Firebase initialization
│   │   ├── car_service.dart                # Query abstraction & multi-filter engine
│   │   ├── dealer_service.dart             # Verification lifecycle & trial assignment
│   │   ├── enquiry_service.dart            # CRM pipeline & contact triggers
│   │   ├── analytics_service.dart          # Lead tracking (WhatsApp, Phone, Views)
│   │   └── payment_service.dart            # Modular Razorpay integration
│   ├── providers/
│   │   ├── auth_provider.dart              # Auth session & dealer switcher
│   │   ├── car_catalog_provider.dart       # Dynamic live car search state
│   │   ├── dealer_portal_provider.dart     # Dealer metrics, stock & CRM pipeline
│   │   └── admin_portal_provider.dart      # Platform KPIs, approvals & settings
│   ├── views/
│   │   ├── public/
│   │   │   ├── home/home_page.dart         # Hero search, brands, cities, dealers
│   │   │   ├── cars/
│   │   │   │   ├── car_search_page.dart    # Dynamic multi-criteria search
│   │   │   │   └── car_detail_page.dart    # Gallery, specs, verified dealer, CTAs
│   │   │   ├── dealers/
│   │   │   │   ├── dealer_directory_page.dart
│   │   │   │   └── dealer_detail_page.dart # Public showroom page & stock
│   │   │   ├── pricing/pricing_page.dart   # 7-Day trial & plan cards
│   │   │   └── auth/
│   │   │       ├── dealer_login_page.dart  # Dealer login & demo switcher
│   │   │       ├── dealer_register_page.dart # 7-Day trial registration
│   │   │       └── admin_login_page.dart   # Super admin credentials login
│   │   ├── dealer_dashboard/
│   │   │   ├── dealer_dashboard_shell.dart # Responsive sidebar & trial countdown
│   │   │   ├── dealer_overview_page.dart   # Lead overview top bar & ROI metrics
│   │   │   ├── dealer_cars_page.dart       # Stock table & slot limit progress
│   │   │   ├── add_edit_car_page.dart      # Photo uploader & specs validator
│   │   │   ├── dealer_enquiries_page.dart  # Interactive CRM lead pipeline
│   │   │   ├── dealer_subscription_page.dart # Plan usage & tier upgrade
│   │   │   └── dealer_profile_page.dart    # Showroom branding & contact
│   │   └── super_admin/
│   │       ├── admin_dashboard_shell.dart  # Admin navigation
│   │       ├── admin_overview_page.dart    # Platform KPIs & MRR
│   │       ├── admin_dealers_page.dart     # Verification approvals
│   │       ├── admin_cars_page.dart        # Featured cars & moderation
│   │       ├── admin_subscriptions_page.dart # Trial extensions & plan activation
│   │       ├── admin_plans_page.dart       # Dynamic pricing configuration
│   │       ├── admin_enquiries_page.dart   # Global platform leads audit
│   │       └── admin_settings_page.dart    # Trial days & moderation toggles
│   └── widgets/
│       ├── common/
│       │   ├── navbar.dart                 # Responsive public header
│       │   ├── footer.dart                 # Footer with dealer trial CTA
│       │   ├── car_card.dart               # Card with pricing, specs & WhatsApp CTA
│       │   ├── enquiry_dialog.dart         # Lead submission popup
│       │   ├── stat_card.dart              # SaaS metric cards
│       │   └── status_badge.dart           # Verification & CRM pills
│       └── charts/
│           └── lead_analytics_chart.dart   # Interactive bar chart (fl_chart)
└── test/
    ├── unit_test.dart                      # 7 core SaaS business logic unit tests
    └── widget_test.dart                    # Formatters & car model unit tests
```

---

## 4. Database Schema (Firestore Collections)

### `dealers`
| Field | Type | Description |
|---|---|---|
| `id` | String | Unique dealer document ID |
| `userId` | String | Auth UID |
| `businessName` | String | Showroom commercial name |
| `slug` | String | Clean SEO slug (e.g. `apex-motors-muktsar`) |
| `logoUrl` | String | URL to dealer logo/photo |
| `phone` | String | Calling phone number |
| `whatsapp` | String | WhatsApp business lead number |
| `city` / `state` | String | Location details |
| `isVerified` | Boolean | True strictly when `verificationStatus == 'verified'` |
| `verificationStatus` | String | `pending` \| `submitted` \| `approved` \| `verified` |
| `verifiedAt` | Timestamp | Date of verification grant |
| `verifiedBy` | String | Admin who verified |
| `status` | String | `approved` \| `suspended` |
| `subscriptionPlanId` | String | `starter` \| `business` \| `pro` |
| `subscriptionStatus` | String | `trial` \| `active` \| `expiring` \| `expired` |
| `trialStartDate` / `trialEndDate` | Timestamp | Free trial timeframe |
| `subscriptionStartDate` / `renewalDate` | Timestamp | Billing cycle dates |

### `cars`
| Field | Type | Description |
|---|---|---|
| `id` | String | Unique vehicle ID |
| `dealerId` | String | Associated dealership ID |
| `title` | String | e.g. `2023 Maruti Suzuki Swift ZXi Plus` |
| `price` | Number | Price in INR (₹) |
| `year` | Number | Manufacturing year |
| `kilometers` | Number | Kilometres driven |
| `fuelType` | String | Petrol, Diesel, CNG, Electric, Hybrid |
| `transmission` | String | Manual, Automatic |
| `bodyType` | String | SUV, Sedan, Hatchback, MUV |
| `isFeatured` | Boolean | True for highlighted placement |
| `featuredStartDate` / `featuredEndDate` | Timestamp | Monetization timeframe |
| `status` | String | `available` \| `sold` \| `inactive` |
| `viewsCount` / `whatsappClicks` / `phoneClicks` | Number | Lead engagement counters |

### `enquiries`
| Field | Type | Description |
|---|---|---|
| `id` | String | Unique enquiry ID |
| `dealerId` | String | Dealership recipient |
| `carId` | String | Interested vehicle |
| `customerName` | String | Buyer name |
| `customerPhone` | String | Buyer contact number |
| `customerEmail` | String | Buyer email |
| `source` | String | `Car Detail Page` \| `WhatsApp` \| `Phone` \| `Enquiry Form` |
| `status` | String | `New` \| `Contacted` \| `Interested` \| `Converted` \| `Closed` |
| `createdAt` | Timestamp | Submission time |

---

## 5. Security & Multi-Tenant Data Isolation

Enforced through `firestore.rules`:
* **Dealer Data Isolation**: Dealers can only query and mutate their own inventory and enquiries (`request.auth.uid == resource.data.dealerId`).
* **Enquiry CRM Privacy**: Dealer A cannot read or view customer leads belonging to Dealer B.
* **Public Access**: Visitors can search available, approved cars and submit enquiries freely without mandatory registration.
* **Super Admin Privilege**: Full platform-wide governance access.

---

## 6. Demo Testing Credentials

### Super Admin Portal:
* **URL**: `/admin/login` or click **"Admin Portal"** in header
* **Email**: `admin@cardealer.com`
* **Password**: `admin123`

### Car Dealer Portal (with 7-Day Trial / Active Plan):
* **URL**: `/login` or click **"Dealer Login"** in header
* **Pre-configured Demo Accounts**:
  * `apex@cardealer.com` (*Apex Motors, Muktsar* — Verified Dealer, Active Plan)
  * `silverline@cardealer.com` (*Silverline Automotive, Bengaluru* — 7-Day Free Trial)
  * `royalwheels@cardealer.com` (*Royal Wheels Autocraft, Delhi NCR* — Pro Plan)
  * `skyline@cardealer.com` (*Skyline Motors, Jaipur* — Expired Trial)
* **Password**: `password123` (or click any of the 1-click Quick Login chips)

---

## 7. Setup & Run Instructions

### Prerequisites
* Flutter SDK (3.41+ or 3.20+)
* Google Chrome or Edge browser (for Web)

### 1. Run Locally (Web):
```bash
cd cardealers
flutter pub get
flutter run -d chrome
```

### 2. Run Automated Test Suite:
```bash
flutter test
```
All 9 core SaaS tests will execute and pass:
* Seed data verification
* 7-day free trial auto-assignment
* Verification pipeline (`Pending` -> `Verified`)
* Conversion analytics & safe division
* Dynamic car search & filtering
* Subscription listing limit enforcement
* Super admin pricing configuration

### 3. Production Web Build:
```bash
flutter build web --release
```
The optimized bundle will be generated at `build/web/`.

---

## 8. Connecting Live Firebase & Razorpay

### Firebase Setup:
1. Create a Firebase Project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Authentication** (Email/Password), **Cloud Firestore**, and **Firebase Storage**.
3. Run `flutterfire configure` to generate your live `firebase_options.dart`, or update the keys in `lib/firebase_options.dart`.
4. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Razorpay Setup:
1. Obtain API Key and Secret from [dashboard.razorpay.com](https://dashboard.razorpay.com).
2. Set `isRazorpayEnabled = true` in **Super Admin Settings** (`/admin/settings`).
3. Pass your `keyId` into `RazorpayService(apiKey: 'rzp_live_...')` in `lib/services/payment_service.dart`.
