import prisma from "../config/database.js";

class ProductRepository {
  constructor() {
    this._prisma = prisma;
  }

  async addProduct(data, categoryId) {
    return this._prisma.product.create({
      data: {
        ...data,
        category: {
          connect: { id: categoryId },
        },
      },
    });
  }

  async getAllProduct() {
    return this._prisma.product.findMany({
      include: {
        category: true,
      },
    });
  }

  async getProductById(productId) {
    return this._prisma.product.findUnique({
      where: {
        id: productId,
      },
    });
  }

  async updateProductById(productId, categoryId, data) {
    return this._prisma.product.update({
      where: {
        id: productId,
      },

      data: {
        ...data,
        category: {
          connect: { id: categoryId },
        },
      },
    });
  }

  async deleteProductById(productId) {
    return this._prisma.product.delete({
      where: {
        id: productId,
      },
    });
  }
}

export default new ProductRepository();
