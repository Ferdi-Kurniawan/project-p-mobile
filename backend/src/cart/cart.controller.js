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

      console.log(`[CART] Adding item: userId=${userId}, productId=${productId}, qty=${quantity}`);

      const product = await this._prisma.product.findUnique({
        where: { id: String(productId) },
        select: { stock: true },
      });

      if (!product) {
        console.log(`[CART] Product not found: ${productId}`);
        return res.status(404).json({ error: "Produk tidak ditemukan." });
      }

      if (quantity > product.stock) {
        return res.status(400).json({
          error: `Stok tidak mencukupi. Stok tersedia: ${product.stock}`,
        });
      }

      const redisKey = `cart:${userId}`;

      let cartData = await client.get(redisKey);
      let cart = cartData ? JSON.parse(cartData) : [];

      const existingItemIndex = cart.findIndex(
        (item) => String(item.productId) === String(productId),
      );

      if (existingItemIndex >= 0) {
        cart[existingItemIndex].quantity += quantity;
      } else {
        cart.push({ productId, quantity });
      }

      await client.setEx(redisKey, 86400, JSON.stringify(cart));
      console.log(`[CART] Saved to Redis: ${redisKey} -> ${JSON.stringify(cart)}`);

      return res
        .status(200)
        .json({ message: "Barang berhasil ditambahkan ke keranjang", cart });
    } catch (error) {
      console.error("[CART ERROR] addItem:", error);
      return res.status(500).json({ error: "Gagal menyimpan keranjang." });
    }
  }

  async getCart(req, res) {
    try {
      const userId = req.session.user.id;
      const redisKey = `cart:${userId}`;

      console.log(`[CART] Fetching cart for userId=${userId}`);

      let cartData = await client.get(redisKey);
      let cartItems = cartData ? JSON.parse(cartData) : [];

      console.log(`[CART] Raw items from Redis:`, cartItems);

      if (cartItems.length === 0) {
        return res.status(200).json({
          message: "Keranjang kosong",
          cart: [],
          total_cart_price: 0,
        });
      }

      const enrichedCart = await Promise.all(
        cartItems.map(async (item) => {
          const product = await this._prisma.product.findUnique({
            where: { id: String(item.productId) },
            select: { name: true, price: true },
          });

          if (!product) {
            console.log(`[CART] Product in Redis not found in DB: ${item.productId}`);
            return null;
          }

          const subtotal = product.price * item.quantity;

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
      const totalCartPrice = finalCart.reduce((sum, item) => sum + item.subtotal, 0);

      console.log(`[CART] Final enriched cart:`, finalCart);

      return res.status(200).json({
        message: "Berhasil mengambil keranjang",
        cart: finalCart,
        total_cart_price: totalCartPrice,
      });
    } catch (error) {
      console.error("[CART ERROR] getCart:", error);
      return res.status(500).json({ error: "Gagal mengambil keranjang." });
    }
  }

  async removeItem(req, res) {
    try {
      const userId = req.session.user.id;
      const { productId } = req.body;
      const redisKey = `cart:${userId}`;

      const product = await this._prisma.product.findUnique({
        where: { id: String(productId) },
        select: { stock: true },
      });

      if (!product) {
        return res.status(404).json({ error: "Produk tidak ditemukan." });
      }

      let cartData = await client.get(redisKey);
      if (!cartData) {
        return res.status(404).json({ error: "Keranjang tidak ditemukan." });
      }

      let cartItems = JSON.parse(cartData);

      const updatedCart = cartItems.filter(
        (item) => String(item.productId) !== String(productId),
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
