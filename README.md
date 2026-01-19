# Work Logger

A high-performance, native macOS application built with Swift and SwiftUI to help developers track their daily tasks, manage plans for tomorrow, and generate standup reports with ease.

## ✨ Features

- **Quick Task Logging**: Easily start tracking tasks with a refined, native macOS UI.
- **Elegant Type Selection**: Choose from various task types (Meeting, Task, Code Review, Planning, etc.) using a sleek dropdown menu.
- **Tomorrow's Plan**: Dedicate a section to plan your next day with titles and detailed notes.
- **Daily Summary**: Visual breakdown of your time spent on meetings vs. deep work.
- **Copy for Standup**: Generate a professional, emoji-rich summary of your daily achievements formatted for team communication.
- **Customizable Reminders**: Schedule morning (planning) and evening (retrospective) notifications at your preferred times.
- **Premium Aesthetics**: Larger fonts, glassmorphism-inspired design, and smooth animations for a top-tier user experience.
- **Global Shortcut**: Use `⌘ K` to quickly bring up the logger from anywhere.
- **Privacy & Persistence**: Local SQLite database for task storage and `UserDefaults` for settings.

## 🚀 Getting Started

### Prerequisites

- macOS (optimized for the latest versions)
- Swift 5.9+

### Building the App

To ensure all features (including high-level notifications) work correctly, the application should be built and run as a proper macOS `.app` bundle.

1. Clone the repository.
2. Run the provided bundling script in the root directory:
   ```bash
   ./bundle_app.sh
   ```
3. Locate `WorkLogger.app` in the project root.
4. **Important**: For the best experience (including notification permissions), drag `WorkLogger.app` to your `/Applications` folder.

### Running for Development

You can run the executable directly via Swift Package Manager, but note that **notifications will be gracefully disabled** in this mode to prevent crashes associated with missing bundle identifiers:

```bash
swift run WorkLogger
```

## 🛠 Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI (AppKit integration for NSPanel support)
- **Database**: SQLite.swift
- **Architecture**: MVVM
- **Tooling**: Swift Package Manager (SPM)

## 📦 Project Structure

- `WorkLoggerLib`: Core logic, views, view models, and managers.
- `WorkLogger`: Executable target containing the `AppDelegate` and window management logic.
- `WorkLoggerTests`: Comprehensive unit tests for core functionality.

---
*Stay productive, one task at a time.*
