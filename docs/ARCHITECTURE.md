# Architecture

## Overview

Pakeeza POS is a **local-first** Windows desktop application. All business data lives in **SQLite** on the counter PC. No cloud server is required.

```
┌─────────────────────────────────────────────────┐
│              Flutter UI (Dart)                   │
│  Auth │ POS │ Orders │ Reports │ Settings        │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Provider (state: auth session, cart)              │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Repositories (auth, menu, orders, settings)     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  SQLite (sqflite + sqflite_common_ffi on Windows)  │
│  File: .../data/pakeeza_pos.db                     │
└─────────────────────────────────────────────────┘

Printer (future) ──► PrinterService (stub) ──► USB / LAN ESC-POS
```

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter 3, Material 3 dark theme |
| State | `provider` |
| Database | SQLite via `sqflite` + `sqflite_common_ffi` |
| Paths | `path_provider` |
| Passwords | `crypto` (salt + SHA-256) |
| Session hint | `shared_preferences` (user id only, no password) |
| Platform | **Windows desktop** (primary) |

## Folder structure

```
lib/
  main.dart                 # Entry, DB init
  app.dart                  # MaterialApp, auth gate
  core/
    constants/              # App-wide constants
    theme/                  # Colors, ThemeData
    utils/                  # Currency, password hash
  data/
    database/               # DatabaseHelper
    models/                 # User, Product, Order, Cart...
    repositories/           # Data access
    seed/                   # Menu seed from flyer
  features/
    auth/                   # Login / Sign up
    shell/                  # Bottom navigation
    pos/                    # Ordering UI
    orders/                 # Today’s orders
    reports/                # Daily summary
    settings/               # Shop info, backup, logout
  providers/                # AuthProvider, CartProvider
  services/
    printer_service.dart    # Stub — future printing
docs/                       # Project documentation
```

## Main flows

### Authentication

1. App starts → `DatabaseHelper` opens SQLite.  
2. `AuthProvider.init()` checks if any user exists.  
3. No users → Sign Up tab, first account = **owner**.  
4. Login validates username/password against `users` table.  
5. Logout clears in-memory session.

### Order flow

1. Cashier selects **category** → **product**.  
2. If multiple **variants** (size/portion), picker dialog.  
3. Lines go to **CartProvider**.  
4. **Complete order** → `OrderRepository.createOrder()` in a transaction.  
5. `PrinterService.printReceipt()` called (no-op until printer phase).

### Reports

- Aggregates `orders` / `order_items` where `created_at` is today (local midnight).

## Offline guarantees

- No HTTP calls in v1.  
- Menu seeded once into SQLite.  
- Works with Wi‑Fi off / no router.

## Future extensions

- Thermal printer (`PrinterService`)  
- Owner-only user management  
- Cloud backup sync  
- Kitchen display (second window / device)
