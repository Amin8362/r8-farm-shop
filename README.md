# R8Force Farm & Shop

A stage-based **Farm & Shop Tycoon** game for Android built with **Flutter & Dart**, combining real-time crop farming, live customer orders, automation upgrades, procedural audio, and persistent offline progress.

[![Download APK](https://img.shields.io/badge/Download-Latest_APK-10B981?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Amin8362/r8-farm-shop/releases/latest)

---

## Features

- **Simultaneous Farm & Shop Loop:** Plant and harvest 5 unlockable crops (Wheat, Strawberry, Corn, Pumpkin, Saffron) while serving 3 live customers with patience bars, speed tips, and combo streaks.
- **10 Handcrafted Stages + Endless Mastery:** Clear mission goals to unlock plots, new seeds, and coin rewards.
- **Upgrades & Automation:** Smart Irrigation, Golden Fertilizer (2x yield chance), Shop Appeal, **Auto-Farmer**, and **Auto-Cashier**.
- **Persistent Local Save:** Progress and crop timers are saved locally via `shared_preferences`, allowing crops to keep growing even while the app is closed.
- **Procedural Sound Effects:** Real-time synthesized WAV audio for planting, harvesting, cash register sales, upgrades, and stage clear fanfare.

## Project Structure

- `lib/game_models.dart` — Crop catalog, upgrade formulas, 10+ stage definitions, and JSON serialization.
- `lib/game_engine.dart` — Real-time game loop, customer AI, auto-workers, and persistent storage.
- `lib/sound_engine.dart` — Procedural PCM/WAV sound synthesizer.
- `lib/main.dart` — Emerald dark UI, live farm grid, customer strip, and upgrade/barn sheets.

## Installation (Android)

1. Open the [**Releases**](https://github.com/Amin8362/r8-farm-shop/releases/latest) page.
2. Download **`app-arm64-v8a-release.apk`** and install it on your Android device.

---

<div dir="rtl">

### معرفی فارسی

**مزرعه و فروشگاه R8Force** یک بازی مرحله‌ای و اعتیادآور در سبک مدیریت مزرعه و فروشگاه است که شامل ۱۰ مرحله طراحی‌شده + مراحل بی‌نهایت، ۵ محصول کشاورزی، مشتریان زنده با نوار صبر و انعام سرعت، سیستم ارتقا و کارمندان خودکار (کشاورز و صندوق‌دار)، افکت صوتی زنده و ذخیره دائمی پیشرفت روی گوشی است. فایل نصب اندروید در بخش **Releases** در دسترس است.

</div>

---

**Author:** Amin Shirdeli (`R8Force`) • **License:** MIT
