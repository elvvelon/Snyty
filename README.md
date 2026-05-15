# 🌙 Snyty

**Smart sleep tracker that helps you wake up refreshed — every time.**

Snyty is a native iOS application designed to track, calculate, and optimize sleep. Built with a focus on scientifically backed sleep cycles and biorhythms to help users wake up feeling refreshed by calculating the perfect time to fall asleep or wake up.

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26+-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0070C9?style=flat)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-6C47FF?style=flat)]()
[![Localization](https://img.shields.io/badge/Localization-EN%20%7C%20UK-34C759?style=flat)]()


---

## 📱 Previews

<p align="center">
  <img src="https://github.com/user-attachments/assets/4567ad98-f933-46b9-a80a-d70d56b4cfcc" width="250" />
  <img src="https://github.com/user-attachments/assets/431a6975-4cf6-448a-a953-fd720188ede3" width="250" />
  <img src="https://github.com/user-attachments/assets/1affb0de-bf55-4a89-950d-1fa63e9e084f" width="250" />
  <img src="https://github.com/user-attachments/assets/1a34505d-13f1-4fdc-812a-685ef545552d" width="250" />
  <img src="https://github.com/user-attachments/assets/67f91a0c-f7e8-4f89-b839-b0f328a9f1ec" width="250" />
</p>

---
## 📖 About

Most alarms wake you up at a fixed time — regardless of what sleep phase you're in. Snyty solves this by scheduling alarms at the end of a complete 90-minute cycle, the natural boundary between sleep phases, so your body is already transitioning toward wakefulness.

---

## ✨ Features

### 🧮 Sleep Calculator
- Enter your desired wake-up time → get up to 6 optimal bedtimes
- Or tap **"I'm going to sleep now"** → get the best alarm times starting from this moment
- Accounts for your personal fall-asleep duration (configurable)

### ⏰ Smart Alarms
- Powered by native **AlarmKit** — alarms fire even if the app is closed
- Full alarm editor: time, sound, snooze toggle and duration
- Alarm list shows time remaining and number of sleep cycles

### 😴 Power Nap
- **20 min** — light recovery nap
- **90 min** — full sleep cycle nap
One tap, alarm set, done.

### 📊 Biorhythm Chart
- Visualizes **Melatonin** and **Cortisol** levels throughout the day
- Curves are personalized using your chronotype offset
- Built with Apple's native **Charts** framework

### 🔔 Bedtime Reminder
- Set a reminder so you don't miss your planned bedtime
- Scheduled via **UserNotifications**, works in the background

### 🎵 15 Custom Alarm Sounds
- Preview any melody directly in Settings before setting it as default
- Audio powered by **AVFoundation**

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM + `@Observable` macro |
| Alarms | AlarmKit + AppIntents |
| Notifications | UserNotifications |
| Charts | Swift Charts (Apple) |
| Audio | AVFoundation |
| Persistence | UserDefaults + local JSON |
| Localization | String Catalogs (`.xcstrings`) |

---

## 🏗 Architecture

The project follows **MVVM** with Apple's modern `@Observable` macro (Swift 5.9+), which replaces the older `ObservableObject` / `@Published` pattern with cleaner, more performant state tracking.

```
SnytyApp
├── ContentView              ← Root router (Onboarding vs. Main Tabs)
│
├── Features/
│   ├── Onboarding/          ← Welcome, chronotype detection, permissions
│   ├── SleepCalculation/    ← Home dashboard, calculator, biorhythm, power nap
│   ├── Alarms/              ← Alarm list, edit sheet, AlarmKit integration
│   └── Settings/            ← User preferences
│
├── Shared/
│   ├── UIComponents/        ← Custom controls: TabPicker, TimePicker, SlidePicker, TogglePicker
│   ├── Style+Extension      ← Design system: colors, typography, .card() modifier
│   └── Services/            ← AppPresetsManager, AlarmScheduleProvider,
│                               BedtimeReminderProvider, AudioPlaybackService
│
└── AlarmSounds/             ← .wav audio assets (ascent, vigor, idle, …)
```

### Key Services

**`AppPresetsManager`** — `@Observable` singleton wrapping UserDefaults. Stores all user settings and automatically triggers UI updates on change.

**`AlarmScheduleProvider`** — Bridge between the UI and system AlarmKit. Handles scheduling, cancellation, and pause/resume. Persists alarm state to `scheduled_alarms.json` so the list survives app restarts.

**`BedtimeReminderProvider`** — Manages local notifications via `UNUserNotificationCenter` for bedtime reminders.

**`BiorhythmViewModel`** — Generates melatonin and cortisol curves using a Gaussian distribution shifted by the user's chronotype offset.

---

## 🎨 Design System

Snyty has a custom design system built entirely in SwiftUI:

- **Theme:** Dark UI with a warm accent palette — Pink/Peach, Yellow, Green, Red
- **Glassmorphism cards:** All panels use a `.card()` modifier — semi-transparent background, glass blur, subtle border, and shadow
- **Typography:** Custom modifiers (`title1()`, `subtitle2()`, `timeStyle()`) defined in `Style+Extension.swift`
- **Custom controls:**
  - `TabPicker` — segmented control
  - `TimePicker` — wheel pickers with haptic feedback (`UIImpactFeedbackGenerator`)
  - `SlidePicker` — custom slider
  - `TogglePicker` — animated toggle replacing the standard `Toggle`
- **Animations:**
  - `SnytyLogoView` — logo drawn with a line-trim animation on appear
  - `StarfieldView` — animated starfield background with pulsing stars, built with `TimelineView` + `Canvas`

---

## 🌍 Localization

Fully localized using **String Catalogs** (`.xcstrings`):
- 🇺🇦 Ukrainian — primary language
- 🇬🇧 English — full support
- Pluralization supported (`1 cycle`, `2 cycles`, `5 cycles`, etc.)

---

## 📋 Requirements

- iOS 26.0+
- Swift 5.9+
- Physical device recommended for AlarmKit testing (AlarmKit has limited Simulator support)

---

## 🚀 Getting Started

```bash
git clone https://github.com/elvvelon/Snyty.git
cd Snyty
open Snyty.xcodeproj
```

Select your target device in Xcode and press **Run** (`⌘R`).

> **Note:** AlarmKit requires a physical iOS device and proper entitlements configured in your Apple Developer account.

> **Audio Management:** To keep the repository lightweight, only a few sample high-quality, royalty-free sounds are included.
---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
