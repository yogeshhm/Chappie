# FalconCRM | Falconate Leads & Relationship Engine

**FalconCRM** is a cross-platform CRM designed specifically for **Falconate** ([falconate.com](https://falconate.com)) to track client relationships, conduct cold calls and WhatsApp outreach, qualify prospects for web and mobile app development, and sync with your **Supabase** cloud database (`https://avoioogdnbyivinkamup.supabase.co`).

---

## 🚀 Key Features

### 1. Pre-loaded with 14 Verified Company Prospects
- All 14 businesses from your AI lead sheet are loaded into local storage and ready for outreach.
- **Verification Badging**:
  - **Company Identity**: Marked as verified.
  - **Nested Data**: Flagged with an interactive toggle so you can audit websites, phones, and handles on each call.
- **Caution Flags & Banners**:
  - **Shrinidhi Enterprises**: Warning against attributing the unrelated Mangaluru HVAC domain to this Hassan FMCG distributor.
  - **M/S Deep Enterprises Solar**: Domain verification notice.
  - **FalconNest Constructions**: Existing site detected — instructions to pitch redesign/SEO/mobile app rather than a new site.

### 2. Multi-Channel Outreach Dock
- 📞 **1-Tap Direct Call**: Dials the prospect immediately using your device's native phone dialer.
- 💬 **1-Tap WhatsApp Pitch**: Formats personalized messages with business name, location, and services offering Falconate's app & web development capabilities.
- ✉️ **Email Launcher**: Opens email client with Falconate intro templates.
- 📸 **Instagram Profile**: Opens the prospect's Instagram page directly.
- 📍 **Google Maps**: Visualizes the client's location and business address.

### 3. Lead Relationship Pipeline & Kanban
- **Call Outcome Logger**: Immediately record whether the prospect is **Interested (Hot)**, requested a **Follow-up**, had **No Answer**, or is **Not Interested**.
- **Interactive Kanban Board**: Visual columns for `Not Called`, `Outreach Sent`, `Interested 🔥`, `Follow-up Due`, `Closed Won 🎉`, and `Cold`. Tap or drag to advance stages.
- **Next Follow-up Reminders**: Date & time picker with due notifications.
- **Auditable Interaction Timeline**: Full chronological history of every call, pitch, and note logged for each client.

### 4. Supabase Cloud Sync & Offline-First
- **URL**: Pre-configured to `https://avoioogdnbyivinkamup.supabase.co`.
- **Offline First**: All changes work instantly offline with persistent local storage.
- **1-Click Cloud Sync**: When connected with your Supabase Anon Key, all leads and call logs sync bidirectionally with Supabase.

---

## 🛠️ Supabase Setup (3 Minutes)

1. Open your Supabase Dashboard: [https://avoioogdnbyivinkamup.supabase.co](https://avoioogdnbyivinkamup.supabase.co)
2. Go to **SQL Editor** -> **New Query**.
3. Copy and paste the contents of `supabase_schema.sql` (located in the project root) and click **Run**.
4. In Supabase, go to **Project Settings** -> **API** -> copy the **Project API Key** (`anon` `public`).
5. In the FalconCRM app, open **Settings** (tab 4), paste the **Anon Key**, and tap **Save & Connect Supabase**.

---

## 📱 How to Run

### Run on Android (Device or Emulator)
```bash
flutter run -d android
```

### Run on Web (Chrome Dashboard)
```bash
flutter run -d chrome
```

### Run on macOS Desktop
```bash
flutter run -d macos
```

### Build Web Production Release
```bash
flutter build web --release
```
The compiled web dashboard is in `build/web/`.

### Build Android APK
```bash
flutter build apk --release
```
