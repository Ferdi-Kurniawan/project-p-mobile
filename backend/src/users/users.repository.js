import prisma from "../config/database.js";

class UserRepository {
  constructor() {
    this._prisma = prisma;
  }
  // Menambahkan user baru
  async create(userData) {
    return await this._prisma.user.create({
      data: userData,
    });
  }

  // cek username exist
  async findByEmail(email) {
    return await this._prisma.user.findUnique({
        where : {
            email
        }
    })
  }

  

  // Mengambil semua user
  async findAll() {
    return await prisma.user.findMany();
  }

  // Mengambil satu user berdasarkan ID (UUID)
  async findById(id) {
    return await prisma.user.findUnique({
      where: { id },
    });
  }

  // Memperbarui data user
  async update(id, updateData) {
    return await prisma.user.update({
      where: { id },
      data: updateData,
    });
  }

  // Menghapus user
  async delete(id) {
    return await prisma.user.delete({
      where: { id },
    });
  }
}

// Ekspor sebagai instance langsung (Singleton)
export default new UserRepository();