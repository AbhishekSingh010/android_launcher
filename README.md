# Horizon: Glass OS — Agent Core

A world-class, futuristic Android launcher built with Flutter. Horizon combines a premium, minimal, Apple-inspired "Glass UI" with a cinematic, elite mission-control system known as "Agent Mode".

This launcher focuses on calm power, discipline, and psychological immersion, prioritizing productivity and deep focus over flashy visuals.

## Features & Capabilities

### 1. Minimal Home Screen
- **Design Philosophy:** Clean typography, an elegant animated clock, and up to 80% empty space.
- **Dynamic Glass UI:** Features real-time blur (glassmorphism), transparency with subtle noise textures, and dynamic background gradients that change based on your current State Mode (Calm, Focus, Aggressive).
- **Core Dock:** Displays a small curated list of your most critical apps alongside an App Drawer button.

### 2. Universal Search
- **Gesture:** From the Home Screen, **Swipe Down** anywhere.
- **Function:** Instantly opens a unified search interface to quickly find and launch any installed application on your device.

### 3. App Drawer
- **Gesture:** From the Home Screen, **Swipe Up** anywhere, or tap the circular Apps icon in the dock.
- **Function:** Displays a clean, grid-based view of all your installed applications with their actual icons.

### 4. 🕵️‍♂️ AGENT MODE (Hidden Dashboard)
A secret cinematic mission-control dashboard.
- **Gesture:** From the Home Screen, **Long Press** anywhere on the empty space.
- **Modules included:**
  - **Focus Protocol (Timer):** A Pomodoro-style deep work timer. Initiating a focus session dynamically shifts the launcher's background to a deep "Focus" state.
  - **Active Missions:** A built-in task list. Swipe right on any mission to complete and dismiss it with a satisfying animation.
  - **AI Integration (Gemini):** A terminal-style input field where you can securely enter your personal Google Gemini API key to activate the onboard AI assistant.

## Setup Instructions

### Prerequisites
- Flutter SDK installed.
- An Android device or emulator.

### Installation
1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Connect your Android device via USB debugging.
4. Run the app: `flutter run` or build the APK: `flutter build apk --release`.

### Setting as Default Launcher
Once installed on your Android device:
1. Press the physical/virtual **Home Button**.
2. The Android OS will prompt you to select a default Home app.
3. Select **"horizon_launcher"** and choose **"Always"**.
*(Note: You can always change this later in your device's Settings > Apps > Default apps > Home app).*

### Connecting the AI (Gemini)
To use the AI capabilities within the launcher:
1. Obtain an API key from [Google AI Studio](https://aistudio.google.com/).
2. Long press on the Home Screen to enter **Agent Mode**.
3. Scroll down to the "AI INTEGRATION" section.
4. Paste your Gemini API key and tap "AUTHORIZE".
*(The key is stored securely on your device using `shared_preferences` and is never transmitted anywhere else).*
