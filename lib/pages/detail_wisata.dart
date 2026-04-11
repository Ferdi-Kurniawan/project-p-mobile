import 'package:flutter/material.dart';

class DetailWisataPage extends StatelessWidget {
  final Map<String, String> data;

  const DetailWisataPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Header dengan Gambar (SliverAppBar)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              // Nama wisata di header dihilangkan agar tidak tumpang tindih
              background: Image.asset(
                data['img'] ?? '', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            backgroundColor: Colors.deepOrange,
          ),
          
          // 2. Konten Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepOrange),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['loc'] ?? "Lokasi tidak tersedia", 
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Bagian Deskripsi
                  const Text(
                    "Tentang Destinasi", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['deskripsi'] ?? "Deskripsi belum ditambahkan.",
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),

                  // --- BAGIAN GALERI FOTO (DI BAWAH TENTANG DESTINASI) ---
                  const SizedBox(height: 25),
                  const Text(
                    "Galeri Foto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150, 
                    child: _buildGalleryScroll(),
                  ),
                  // -----------------------------------

                  const SizedBox(height: 25),

                  // Bagian Harga Tiket
                  const Text(
                    "Harga Tiket", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      data['harga'] ?? "Gratis", 
                      style: const TextStyle(
                        fontSize: 22, 
                        color: Colors.deepOrange, 
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                // -----------------------------------

                const SizedBox(height: 40),
                
                // Tombol Pesan Tiket
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Menuju pemesanan ${data['name']}...")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Pesan Tiket Sekarang", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // Fungsi untuk membangun scroll galeri horizontal
  Widget _buildGalleryScroll() {
    String galleryString = data['gallery'] ?? '';
    if (galleryString.isEmpty) {
      return Center(
        child: Text("Galeri foto belum tersedia.", style: TextStyle(color: Colors.grey[400])),
      );
    }

    List<String> imageList = galleryString.split(',');

    return ListView.builder(
      scrollDirection: Axis.horizontal, 
      physics: const BouncingScrollPhysics(), 
      itemCount: imageList.length,
      itemBuilder: (context, index) {
        return Container(
          width: 220, 
          margin: const EdgeInsets.only(right: 15, bottom: 5), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network( // Sudah diubah ke network agar ambil dari linkPicsum
              imageList[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      },
    );
  }
}