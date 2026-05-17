# Setup & Windows build

## 1. Install Flutter (Windows)

1. Flutter SDK is at: `C:\Users\hp\flutter`  
2. Add `C:\Users\hp\flutter\bin` to **PATH** (System Environment Variables → Path).  
3. Or run with full path: `C:\Users\hp\flutter\bin\flutter.bat`  
4. Run in PowerShell:

```powershell
flutter doctor
```

Enable **Windows desktop**:

```powershell
flutter config --enable-windows-desktop
```

Install **Visual Studio 2022** with workload **"Desktop development with C++"** (required for Windows builds).

---

## 2. Generate platform folders (first time only)

From the project folder:

```powershell
cd d:\umair\pakeeza_pos
flutter create . --project-name pakeeza_pos --platforms=windows
flutter pub get
```

This adds the `windows/` runner without overwriting `lib/`.

---

## 3. Run in development

```powershell
flutter run -d windows
```

Hot reload: press `r` in the terminal.

---

## 4. Release build (for other laptops)

```powershell
flutter build windows --release
```

**Do not copy the `Debug` folder** — it will fail on other PCs.

### Ready-made package (after build)

| What | Path |
|------|------|
| **ZIP to send** | `d:\umair\pakeeza_pos\dist\PakeezaPOS-Windows-x64.zip` |
| **Unzipped folder** | `d:\umair\pakeeza_pos\dist\PakeezaPOS\` |

On the shop PC: unzip → open `PakeezaPOS` folder → run `pakeeza_pos.exe`  
Must keep **all files** (`flutter_windows.dll`, `sqlite3.dll`, `data\` folder).

If error mentions `VCRUNTIME140.dll`, install:  
https://aka.ms/v14/vc/redist/x64/VC_redist.x64.exe

Raw build output:

```
build\windows\x64\runner\Release\
  pakeeza_pos.exe
  flutter_windows.dll
  sqlite3.dll
  data\
```

Copy the **entire `Release` folder** (or use the ZIP above).

---

## 5. Create `Setup.exe` (recommended for the restaurant)

### Option A — ZIP (quick)

1. Zip the `Release` folder as `PakeezaPOS.zip`.  
2. Unzip on counter PC → run `pakeeza_pos.exe`.  
3. Optional: pin shortcut to desktop.

### Option B — Inno Setup (professional installer)

1. Install [Inno Setup](https://jrsoftware.org/isinfo.php).  
2. Create script pointing `Source` to `build\windows\x64\runner\Release\*`.  
3. Compile → `PakeezaPOS-Setup.exe`.  
4. Owner runs installer → Start Menu shortcut.

### Option C — MSIX (optional)

```powershell
flutter pub add msix --dev
# configure msix in pubspec, then:
dart run msix:create
```

---

## 6. First run at the shop

1. Install / open **Pakeeza POS**.  
2. **Sign Up** → create **owner** account (first user only).  
3. Confirm menu categories appear on POS tab.  
4. Settings → verify shop name, address, phones.  
5. Export a **backup** after first day.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `flutter` not found | Add Flutter `bin` to PATH, restart terminal |
| Visual Studio missing | Install C++ desktop workload |
| Blank window | Run `flutter pub get`, rebuild |
| Database locked | Close second copy of the app |

---

## Updating the app

1. Build new `Release` on your dev PC.  
2. Install over old version **or** replace folder.  
3. Database in AppData is kept if app id/path unchanged.  
4. **Backup database before updating.**
