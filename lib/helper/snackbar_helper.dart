import 'package:flutter/material.dart';

class CustomSnackBar {
  static const Color tealDeep = Color(0xFF319795);
  static const Color darkGrey = Color(0xFF1A202C);

  // Menyimpan overlay yang sedang aktif agar tidak numpuk kalau dipencet berkali-kali
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, String message, bool isSuccess) {
    // 1. Hapus SnackBar lama jika masih ada di layar
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }

    // 2. Buat widget SnackBar dengan Z-Index paling depan (OverlayEntry)
    _currentEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          // Posisi absolute seperti di CSS
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              40, // Akan naik otomatis jika keyboard terbuka
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: darkGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSuccess
                      ? tealDeep.withOpacity(0.5)
                      : Colors.redAccent.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? tealDeep.withOpacity(0.2)
                          : Colors.redAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: isSuccess ? tealDeep : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // 3. Masukkan ke dalam Overlay utama aplikasi
    Overlay.of(context).insert(_currentEntry!);

    // 4. Buat timer untuk menghilangkan SnackBar secara otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentEntry != null) {
        _currentEntry!.remove();
        _currentEntry = null;
      }
    });
  }
}
