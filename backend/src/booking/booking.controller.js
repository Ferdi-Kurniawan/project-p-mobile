import bookingRepository from "./booking.repository.js";
import client from "../config/redis.js";
import prisma from "../config/database.js";
import { json } from "express";

const createBooking = async (req, res) => {
  try {
    const userId = req.session.user.id;
    const { startDate, endDate } = req.body;
    const redisKey = `cart:${userId}`;

    const cartData = await client.get(redisKey);
    const cartItems = cartData ? JSON.parse(cartData) : [];

    if (cartItems.length === 0) {
      return res.status(400).json({
        error:
          "Keranjang belanja Anda kosong. Harap memilih produk terlebih dahulu.",
      });
    }

    let calculatedTotalPrice = 0;
    const finalItems = [];

    for (const item of cartItems) {
      const product = await prisma.product.findUnique({
        where: { id: item.productId },
        select: { price: true },
      });

      if (!product) {
        throw new Error(`PRODUCT_NOT_FOUND_${item.productId}`);
      }

      calculatedTotalPrice += product.price * item.quantity;

      finalItems.push({
        productId: item.productId,
        quantity: item.quantity,
        price: product.price,
      });
    }

    const result = await bookingRepository.createBookingWithTransaction(
      userId,
      startDate,
      endDate,
      calculatedTotalPrice,
      finalItems,
    );

    await client.del(redisKey);

    return res.status(201).json({
      message: "Booking berhasil dibuat",
      data: { booking: result },
    });
  } catch (error) {
    if (error.message && error.message.includes("INSUFFICIENT_STOCK")) {
      const productId = error.message.split("_")[2];
      return res.status(400).json({
        error: `Pemesanan gagal. Stok tidak mencukupi untuk produk ID: ${productId}`,
      });
    }

    if (error.message && error.message.includes("PRODUCT_NOT_FOUND")) {
      return res.status(400).json({
        error:
          "Pemesanan gagal. Ada produk di keranjang Anda yang sudah tidak tersedia.",
      });
    }

    console.error("Database Error:", error);
    return res.status(500).json({
      error: "Terjadi kesalahan internal pada server.",
    });
  }
};

const getBookings = async (req, res) => {
  try {
    const userId = req.session.user.id;
    const bookings = await bookingRepository.getBookingsByUserId(userId);
    return res.status(200).json({
      data: {
        booking: bookings,
      },
    });
  } catch (error) {
    return res.status(500).json({
      error: "Terjadi kesalahan internal pada server.",
    });
  }
};

const getBookingById = async (req, res) => {
  try {
    const userId = req.session.user.id;
    const { bookingId } = req.params;
    const booking = await bookingRepository.getBookingById(bookingId, userId);

    if (!booking) {
      return res.status(404).json({ error: "Booking tidak ditemukan." });
    }

    return res.status(200).json({
      data: {
        booking: booking,
      },
    });
  } catch (error) {
    console.error("Database Error:", error);
    return res.status(500).json({
      error: "Terjadi kesalahan internal pada server.",
    });
  }
};

const getHistoryBookings = async (req, res) => {
  try {
    const bookings = await bookingRepository.getHistoryBookings();
    return res.status(200).json({
      data: {
        booking: bookings,
      },
    });
  } catch (error) {
    console.error("Database Error:", error);
    return res.status(500).json({
      error: "Terjadi kesalahan internal pada server.",
    });
  }
};

const getHistoryBookingById = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const booking = await bookingRepository.getHistoryBookingById(bookingId);

    if (!booking) {
      return res.status(404).json({ error: "Booking tidak ditemukan." });
    }

    return res.status(200).json({
      data: {
        booking: booking,
      },
    });
  } catch (error) {
    console.error("Database Error:", error);
    return res.status(500).json({
      error: "Terjadi kesalahan internal pada server.",
    });
  }
};

const deleteBookingById = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const userId = req.session.user.id;

    const existingBooking =
      await bookingRepository.getHistoryBookingById(bookingId);

    if (!existingBooking) {
      return res.status(404).json({
        status: "error",
        message: "Booking tidak ditemukan",
      });
    }

    await bookingRepository.deleteBookingById(bookingId);

    return res.status(200).json({
      status: "success",
      message: "Booking berhasil dihapus.",
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      message: "Terjadi kesalahan internal pada server.",
    });
  }
};

export {
  createBooking,
  getBookings,
  getHistoryBookings,
  getHistoryBookingById,
  getBookingById,
  deleteBookingById,
};
