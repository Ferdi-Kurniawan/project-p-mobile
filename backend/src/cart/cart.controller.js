import client from "../config/redis.js";
import prisma from "../config/database.js";
class CartController {
  constructor() {
    this._prisma = prisma;
    this.addItem = this.addItem.bind(this);
    this.getCart = this.getCart.bind(this);
    this.removeItem = this.removeItem.bind(this);
    this.clearCart = this.clearCart.bind(this);
  }

  async addItem(req, res) {
    try {
      const userId = req.session.user.id;

      const { productId, quantity } = req.body;

      const product = await this._prisma.product.findUnique({
        where: { id: productId },
        select: { stock: true },
      });

      if (!product) {
        return res.status(404).json({ error: "Produk tidak ditemukan." });
      }

      if (quantity > product.stock) {
        return res.status(400).json({
          error: `Stok tidak mencukupi. Stok tersedia: ${product.stock}`,
        });
      }

      const redisKey = `cart:${userId}`;

      let cart = await client.get(redisKey);
      cart = cart ? JSON.parse(cart) : [];

      const existingItemIndex = cart.findIndex(
        (item) => item.productId === productId,
      );

      if (existingItemIndex >= 0) {
        cart[existingItemIndex].quantity += quantity;
      } else {
        cart.push({ productId, quantity });
      }

      await client.setEx(redisKey, 86400, JSON.stringify(cart));

      return res
        .status(200)
        .json({ message: "Barang berhasil ditambahkan ke keranjang", cart });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: "Gagal menyimpan keranjang." });
    }
  }

  async getCart(req, res) {
    try {
      const userId = req.session.user.id;
      const redisKey = `cart:${userId}`;

      let cartData = await client.get(redisKey);
      let cartItems = cartData ? JSON.parse(cartData) : [];

      if (cartItems.length === 0) {
        return res.status(200).json({
          message: "Keranjang kosong",
          cart: [],
          total_cart_price: 0,
        });
      }

      let totalCartPrice = 0;

      const enrichedCart = await Promise.all(
        cartItems.map(async (item) => {
          // Cari data produk di DB
          const product = await this._prisma.product.findUnique({
            where: { id: item.productId },
            select: { name: true, price: true },
          });

          if (!product) return null;

          const subtotal = product.price * item.quantity;
          totalCartPrice += subtotal;

          return {
            productId: item.productId,
            name: product.name,
            price: product.price,
            quantity: item.quantity,
            subtotal: subtotal,
          };
        }),
      );

      const finalCart = enrichedCart.filter((item) => item !== null);

      return res.status(200).json({
        message: "Berhasil mengambil keranjang",
        cart: finalCart,
        total_cart_price: totalCartPrice,
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: "Gagal mengambil keranjang." });
    }
  }

  async removeItem(req, res) {
    try {
      const userId = req.session.user.id;
      const { productId } = req.body;
      const redisKey = `cart:${userId}`;

      let cartData = await client.get(redisKey);
      if (!cartData) {
        return res.status(404).json({ error: "Keranjang tidak ditemukan." });
      }

      let cartItems = JSON.parse(cartData);

      const updatedCart = cartItems.filter(
        (item) => item.productId !== productId,
      );

      if (updatedCart.length === 0) {
        await client.del(redisKey);
        return res
          .status(200)
          .json({ message: "Keranjang sekarang kosong.", cart: [] });
      } else {
        await client.setEx(redisKey, 86400, JSON.stringify(updatedCart));
        return res.status(200).json({
          message: "Barang berhasil dihapus dari keranjang.",
          cart: updatedCart,
        });
      }
    } catch (error) {
      console.error(error);
      return res
        .status(500)
        .json({ error: "Gagal menghapus barang dari keranjang." });
    }
  }

  async clearCart(req, res) {
    try {
      const userId = req.session.user.id;
      const redisKey = `cart:${userId}`;

      await client.del(redisKey);

      return res
        .status(200)
        .json({ message: "Keranjang berhasil dikosongkan." });
    } catch (error) {
      return res.status(500).json({ error: "Gagal mengosongkan keranjang." });
    }
  }
}

export default new CartController();
