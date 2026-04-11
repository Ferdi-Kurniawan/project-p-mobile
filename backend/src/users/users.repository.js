import prisma from "../config/database.js";

class UserRepository {
  constructor() {
    this._prisma = prisma;
  }

  async create(userData) {
    return await this._prisma.user.create({
      data: userData,
    });
  }

  async findByEmail(email) {
    return await this._prisma.user.findUnique({
      where: { email }
    });
  }

  // TAMBAHKAN INI: Untuk cek nomor HP duplikat
  async findByPhone(phone) {
    return await this._prisma.user.findFirst({
      where: { phone }
    });
  }

  async findAll() {
    return await this._prisma.user.findMany();
  }

  async findById(id) {
    return await this._prisma.user.findUnique({
      where: { id },
    });
  }

  async update(id, updateData) {
    return await this._prisma.user.update({
      where: { id },
      data: updateData,
    });
  }

  async delete(id) {
    return await this._prisma.user.delete({
      where: { id },
    });
  }
}

export default new UserRepository();