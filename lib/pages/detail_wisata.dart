import 'package:flutter/material.dart';

class DetailWisataPage extends StatelessWidget {
  final Map<String, String> data;
  const DetailWisataPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan Gambar
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

          // Konten Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Wisata
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.deepOrange, size: 20),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['loc'] ?? "Lokasi tidak tersedia",
                          style: const TextStyle(
                              fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Badge Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['kategori'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Divider
                  Divider(color: Colors.grey.shade200),

                  const SizedBox(height: 20),

                  // Tentang Destinasi
                  const Text(
                    "Tentang Destinasi",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['deskripsi'] ?? "Deskripsi belum ditambahkan.",
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 25),

                  // Galeri Foto
                  const Text(
                    "Galeri Foto",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: _buildGalleryScroll(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryScroll() {
    final galleryString = data['gallery'] ?? '';
    if (galleryString.isEmpty) {
      return Center(
        child: Text(
          "Galeri foto belum tersedia.",
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final imageList = galleryString.split(',');
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
            child: Image.asset(
              imageList[index].trim(),
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