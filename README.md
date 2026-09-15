# ⏳ Countdown

A modern and customizable countdown application for tracking important dates and events.

Countdown allows users to create multiple countdowns, track remaining time in real time, receive notifications, configure quiet hours, customize the application theme, export data as CSV, and create or restore complete JSON backups.

---

## ✨ Features

* ⏱️ **Real-time Countdown**

  * Count down to a specific date and time.
  * Display remaining days, hours, minutes, and seconds.
  * Automatically detect when a countdown has expired.

* 📋 **Countdown Management**

  * Create countdowns.
  * Edit existing countdowns.
  * Delete countdowns.
  * View active and completed countdowns.

* 🔔 **Notifications**

  * Enable or disable application notifications.
  * Receive notifications related to countdown events.
  * Configure notification behavior according to user preferences.

* 🌙 **Quiet Hours**

  * Define a period during which notifications are suppressed.
  * Example:
    `22:00 → 07:00`
  * Notifications resume according to the configured settings after quiet hours end.

* 🎨 **Themes**

  * Light theme.
  * Dark theme.
  * System/default theme.
  * Support for additional themes.

* 📤 **CSV Export**

  * Export countdown data as CSV.
  * Share the exported file with other applications.
  * Compatible with spreadsheet applications such as Microsoft Excel and Google Sheets.

* 💾 **JSON Backup**

  * Create a complete backup of application data.
  * Restore data from a JSON backup.
  * Preserve countdowns and supported application settings.

* 🔒 **Local Data**

  * User countdowns and preferences can be stored locally according to the application's storage implementation.

---

## 📱 Screenshots

> Add application screenshots here.

### Home

### Create Countdown

### Countdown Details

### Settings

### Dark Theme

---

## 🧩 Application Overview

The application is organized around four primary areas:

```text
┌─────────────────────────────────────┐
│              Countdown              │
├─────────────────────────────────────┤
│                                     │
│  Countdown Management               │
│  ├── Create                         │
│  ├── Edit                           │
│  ├── Delete                         │
│  └── Track Remaining Time           │
│                                     │
│  Notifications                      │
│  ├── Enable / Disable               │
│  └── Quiet Hours                    │
│                                     │
│  Appearance                         │
│  ├── Light                          │
│  ├── Dark                           │
│  └── System                         │
│                                     │
│  Data Management                    │
│  ├── CSV Export                     │
│  ├── JSON Backup                    │
│  └── JSON Restore                   │
│                                     │
└─────────────────────────────────────┘
```

---

|     |     |
| --- | --- |

# 🔔 Notifications

Notifications are designed to keep users informed about important countdown events.

Possible notification states:

```text
Notification
    │
    ├── Disabled
    │
    └── Enabled
          │
          ├── Quiet Hours Active
          │       └── Suppress Notification
          │
          └── Quiet Hours Inactive
                  └── Deliver Notification
```

### Quiet Hours

Example configuration:

```json
{
  "enabled": true,
  "start": "22:00",
  "end": "07:00"
}
```

The notification service should evaluate quiet-hour rules before scheduling or displaying notifications.

For periods crossing midnight, for example `22:00 → 07:00`, the implementation should treat the interval as spanning two calendar days.

---

# 🎨 Themes

The application supports configurable appearance settings.

### Available themes

* Light
* Dark
* System

The selected theme should persist between application launches.

A future implementation can extend the theme system with custom color palettes or user-created themes.

---

# 📤 CSV Export

Countdown data can be exported as CSV.

Example:

```csv
id,title,targetDate,status
1,New Year,2027-01-01T00:00:00,active
2,Project Deadline,2026-12-15T18:00:00,active
3,Birthday,2027-03-20T12:00:00,upcoming
```

CSV export is intended for:

* Data sharing.
* Spreadsheet applications.
* External analysis.
* Human-readable data exports.

The CSV format should remain backward-compatible where possible.

---

# 💾 JSON Backup & Restore

JSON is used as the application's backup format.

Example:

```json
{
  "version": 1,
  "exportedAt": "2026-09-14T20:00:00",
  "countdowns": [
    {
      "id": "1",
      "title": "New Year",
      "targetDate": "2027-01-01T00:00:00",
      "notificationEnabled": true
    }
  ],
  "settings": {
    "theme": "dark",
    "notificationsEnabled": true,
    "quietHours": {
      "enabled": true,
      "start": "22:00",
      "end": "07:00"
    }
  }
}
```

### Backup

1. Open **Settings**.
2. Select **Backup / Export**.
3. Select **JSON Backup**.
4. Save or share the generated file.

### Restore

1. Open **Settings**.
2. Select **Restore Backup**.
3. Select a valid JSON backup.
4. Validate the backup.
5. Restore the supported data.

### Backup Versioning

The `version` field allows future versions of the application to migrate older backup formats.

Example:

```json
{
  "version": 2
}
```

When the backup schema changes, a migration mechanism should be implemented instead of silently interpreting an older schema as the newest one.

---

# 🧪 Testing

The project should include tests for both core business logic and user-facing functionality.

### Recommended test coverage

#### Countdown

* [ ] Correct remaining time calculation.
* [ ] Countdown expiration.
* [ ] Past target dates.
* [ ] Leap years.
* [ ] Month/year boundaries.
* [ ] Time-zone handling.
* [ ] Daylight-saving transitions where applicable.

#### Notifications

* [ ] Notifications enabled.
* [ ] Notifications disabled.
* [ ] Quiet Hours enabled.
* [ ] Quiet Hours crossing midnight.
* [ ] Notification after Quiet Hours.

#### Backup

* [ ] JSON export.
* [ ] JSON import.
* [ ] Invalid JSON handling.
* [ ] Backup version compatibility.

#### CSV

* [ ] CSV generation.
* [ ] Special characters.
* [ ] Commas and quotes inside titles.
* [ ] Empty datasets.

#### Themes

* [ ] Light theme.
* [ ] Dark theme.
* [ ] System theme.
* [ ] Theme persistence.

Run tests using:

```bash
YOUR_TEST_COMMAND
```

---

# 🔐 Privacy & Data Security

The application should follow a privacy-first approach.

* Countdown data should only be transmitted externally if explicitly required by the application.
* Exported CSV and JSON files are controlled by the user.
* Backup files may contain personal information such as event names and dates.
* Users should store backup files in trusted locations.
* Sensitive credentials or secrets must never be included in backup files unless explicitly required and securely encrypted.

---

# 🗺️ Roadmap

## Countdown

* [x] Create countdown
* [x] Edit countdown
* [x] Delete countdown
* [x] Real-time remaining time
* [ ] Recurring countdowns
* [ ] Countdown categories
* [x] Custom countdown colors
* [ ] Countdown images

## Notifications

* [x] Enable / disable notifications
* [x] Quiet Hours
* [ ] Custom notification messages
* [ ] Multiple reminder intervals
* [ ] Custom notification sounds

## Data

* [x] CSV export
* [x] JSON backup
* [x] JSON restore
* [ ] Automatic backups
* [ ] Encrypted backups
* [ ] Cloud synchronization

## UI

* [x] Light theme
* [x] Dark theme
* [x] System theme
* [ ] Custom themes
* [ ] Home-screen widgets

## Sharing

* [x] CSV sharing
* [x] Share countdown as image
* [ ] Share countdown via deep link
* [ ] Public countdown links

---

# 🤝 Contributing

Contributions are welcome.

### Development workflow

1. Fork the repository.
2. Create a feature branch.

```bash
git checkout -b feature/your-feature
```

3. Implement your changes.
4. Add or update tests.
5. Run the test suite.
6. Commit your changes.

```bash
git commit -m "feat: add your feature"
```

7. Push the branch.

```bash
git push origin feature/your-feature
```

8. Open a Pull Request.

### Commit Convention

Recommended commit prefixes:

```text
feat:     New feature
fix:      Bug fix
refactor: Code refactoring
docs:     Documentation
test:     Tests
chore:    Maintenance
perf:     Performance improvement
```

---

# 🐛 Issues & Bug Reports

If you encounter a bug, open an issue and provide:

* Application version.
* Operating system and version.
* Device information where relevant.
* Steps to reproduce the problem.
* Expected behavior.
* Actual behavior.
* Relevant logs or screenshots.

Please do not include private information in public issues.

---

# 📋 Project Status

**Status:** `In Development`

The project is actively being developed. Features and APIs may change between releases.

---

# 📄 License

This project is distributed under the license specified in the [`LICENSE`](LICENSE) file.

If the project does not yet have a license, add one before allowing external contributions or redistribution.

---

# 👤 Author

**Your Name**

* GitHub: `@`M4A28
* Project: `Countdown`

---

# ⭐ Support the Project

If you find the project useful, consider giving the repository a ⭐ on GitHub.

For bugs, feature requests, or technical discussions, use the project's GitHub Issues and Discussions sections.
