# Pakeeza POS

Offline point-of-sale desktop app for **Pakeeza Fast Food & Pizza Point** (Windows).

Built with **Flutter** + **SQLite**. Works without internet. Receipt **printer support is planned for a later release**.

## Features

| Feature | Status |
|---------|--------|
| Full menu from restaurant flyer | ✅ |
| Size / portion pricing (pizza S/M/L, wings, fries, etc.) | ✅ |
| Cart & checkout (Cash / Card / Online) | ✅ |
| Login & sign up (local accounts) | ✅ |
| Product visuals (animated pizza box, category icons) | ✅ |
| Today's orders & daily reports | ✅ |
| Shop settings & database backup | ✅ |
| Windows `.exe` installer | ✅ (see [docs/SETUP.md](docs/SETUP.md)) |
| Thermal receipt printer | 🔜 Later |

## Quick start (after Flutter is installed)

```powershell
cd d:\umair\pakeeza_pos
flutter create . --project-name pakeeza_pos --platforms=windows
flutter pub get
flutter run -d windows
```

First launch: use **Sign Up** to create the **owner** account (first user only). Then use **POS** to take orders.

## Build Windows installer

```powershell
flutter build windows --release
```

See [docs/SETUP.md](docs/SETUP.md) for creating a `Setup.exe` with Inno Setup.

## Documentation

| Document | Description |
|----------|-------------|
| [docs/SETUP.md](docs/SETUP.md) | Install Flutter, run app, build exe |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Stack, folders, data flow |
| [docs/DATABASE.md](docs/DATABASE.md) | Tables and schema |
| [docs/AUTH.md](docs/AUTH.md) | Login, sign up, roles |
| [docs/MENU.md](docs/MENU.md) | Menu items and prices |
| [docs/PRINTER.md](docs/PRINTER.md) | Future printer integration |
| [docs/USER_GUIDE.md](docs/USER_GUIDE.md) | Guide for shop staff |
| [docs/PRODUCT_IMAGES.md](docs/PRODUCT_IMAGES.md) | Custom product photos |

## Data location

Database file (all orders and users):

`%APPDATA%\pakeeza_pos\data\pakeeza_pos.db`  
(or under application support directory — see Settings screen in app)

Backups exported from Settings are saved under Documents → `PakeezaPOS\backups\`.

## Flutter SDK path (this machine)

`C:\Users\hp\flutter\bin` — add to PATH, or use:

```powershell
C:\Users\hp\flutter\bin\flutter.bat run -d windows
```

## License

Private / restaurant use.
