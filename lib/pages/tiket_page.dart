import 'package:flutter/material.dart';

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAktifSelected = true; // State untuk kontrol tab

  // Data dummy Tiket Aktif
  final List<Map<String, String>> _activeTickets = [
    {
      'title': 'Tiket Masuk Desa Penglipuran',
      'date': '12 April 2026',
      'status': 'Aktif',
      'code': 'TRX-99281',
      'img': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4'
    },
  ];

  // Data dummy Riwayat Tiket
  final List<Map<String, String>> _historyTickets = [
    {
      'title': 'E-Tiket Desa Wae Rebo',
      'date': '01 Maret 2026',
      'status': 'Selesai',
      'code': 'TRX-11203',
      'img': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2'
    },
    {
      'title': 'Wisata Budaya Desa Sade',
      'date': '15 Feb 2026',
      'status': 'Selesai',
      'code': 'TRX-00561',
      'img': 'https://images.unsplash.com/photo-1555400038-63f5ba517a47'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan data list berdasarkan tab yang dipilih
    final currentList = _isAktifSelected ? _activeTickets : _historyTickets;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepOrange.shade800, Colors.orange.shade400],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTicketTabs(),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    // Menggunakan AnimatedSwitcher agar perpindahan tab halus
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: currentList.isEmpty 
                        ? _buildEmptyState() 
                        : _buildTicketList(currentList),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Tiket Saya",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTicketTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            _tabItem("Aktif", _isAktifSelected, () => setState(() => _isAktifSelected = true)),
            _tabItem("Riwayat", !_isAktifSelected, () => setState(() => _isAktifSelected = false)),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.deepOrange : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, String>> list) {
    return ListView.builder(
      key: ValueKey(_isAktifSelected), // Penting untuk animasi ganti tab
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _ticketCard(list[index], !_isAktifSelected);
      },
    );
  }

  Widget _ticketCard(Map<String, String> ticket, bool isHistory) {
    return Opacity(
      opacity: isHistory ? 0.7 : 1.0, // Tiket riwayat agak transparan
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  // Gambar (Grayscale jika riwayat)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColorFiltered(
                      colorFilter: isHistory 
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: Image.network(ticket['img']!, height: 70, width: 70, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(ticket['date']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildDashedLine(),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ticket['code']!, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  isHistory 
                    ? const Text("Selesai", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Lihat QR"),
                      ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: List.generate(30, (i) => Expanded(
          child: Container(color: i % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.2), height: 1),
        )),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Belum ada riwayat tiket", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}