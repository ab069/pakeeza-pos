# Receipt printer (planned)

## Current status

**Not implemented in v1.**

- `lib/services/printer_service.dart` is a **stub**.  
- Checkout completes orders normally; no paper receipt is printed.  
- Settings shows: *Printer not configured yet.*

## When you are ready

Collect this information from the shop:

1. Printer **brand and model** (e.g. Epson TM-T82, Xprinter XP-80)  
2. Connection type: **USB** or **Wi‑Fi/LAN**  
3. Paper width: **58mm** or **80mm**  

## Planned implementation

| Connection | Approach |
|------------|----------|
| **LAN / Wi‑Fi** | Send **ESC/POS** bytes to printer IP (port 9100) |
| **USB (Windows)** | Flutter plugin or platform channel + Windows driver |

### Code hook

After successful checkout, `PosScreen` already calls:

```dart
PrinterService.instance.printReceipt(...)
```

When implemented, this will:

1. Load shop name, address, phones from `settings`  
2. Format line items, total, payment method  
3. Send cut command to thermal printer  

### Packages (candidates)

- `esc_pos_utils` + network socket  
- `printing` (PDF) as fallback preview  
- Windows-specific plugin for USB  

## Testing checklist (later)

- [ ] Test print from Settings  
- [ ] Full order receipt after checkout  
- [ ] Urdu/English shop name prints correctly  
- [ ] Re-print last order (optional)  

## Until then

Use **Orders** tab to view order details on screen.
