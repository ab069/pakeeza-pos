/// Receipt printer integration — **planned for a future release**.
///
/// See [docs/PRINTER.md] for setup when hardware is available.
class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  bool get isConfigured => false;

  String get statusMessage =>
      'Printer not configured yet. Receipt printing will be added in a future update.';

  /// Placeholder: will send ESC/POS bytes to USB or network thermal printer.
  Future<bool> printReceipt({
    required Map<String, String> shopSettings,
    required int orderId,
    required List<Map<String, dynamic>> lines,
    required int total,
    required String paymentMethod,
    String? cashierName,
  }) async {
    // TODO: Implement when printer model is confirmed (USB / LAN ESC-POS).
    return false;
  }

  /// Placeholder: test print from Settings screen.
  Future<bool> testPrint() async {
    return false;
  }
}
