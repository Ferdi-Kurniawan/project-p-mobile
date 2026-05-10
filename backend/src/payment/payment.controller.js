import PaymentRepository from "./payment.repository.js";
import bookingRepository from "../booking/booking.repository.js";
const updatePayment = async (req, res, next) => {
  try {
    // 1. TAMBAHKAN VALIDASI INI PALING ATAS
    if (!req.file) {
      return res.status(400).json({
        status: "error",
        message: "Bukti pembayaran (file gambar) wajib diunggah!",
      });
    }

    const { bookingId } = req.params;
    const { payment_method } = req.body;
    const userId = req.session.user.id; // Dari session/token login

    // 2. Ambil filename setelah dipastikan req.file ada
    const filename = req.file.filename;

    // Eksekusi update di repository
    const updatedBooking = await PaymentRepository.updatePaymentProof(
      bookingId,
      userId,
      payment_method,
      filename,
    );

    res.status(200).json({
      status: "success",
      message: "Pembayaran berhasil dikonfirmasi dan status menjadi PAID.",
      data: updatedBooking,
    });
  } catch (error) {
    // Tangani error khusus dari Prisma jika data tidak ditemukan / bukan milik user
    if (error.code === "P2025") {
      return res.status(404).json({
        status: "error",
        message:
          "Booking tidak ditemukan atau Anda tidak memiliki akses ke booking ini.",
      });
    }

    // Lempar error lain ke global error handler (app.js)
    next(error);
  }
};

const getPaymentProof = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const userId = req.session.user.id;

    const booking = await bookingRepository.getBookingById(bookingId);
    if (!booking) {
      return res.status(404).json({
        status: "error",
        message: "Booking tidak ditemukan.",
      });
    }

    if (booking.user_id !== userId) {
      return res.status(403).json({
        status: "error",
        message: "Anda tidak memiliki akses ke pembayaran ini.",
      });
    }

    const paymentProofUrl = booking.payment_proof
      ? `${req.protocol}://${req.get("host")}/payment/${booking.payment_proof}`
      : null;

    res.status(200).json({
      status: "success",
      data: {
        payment_proof: booking.payment_proof,
        payment_proof_url: paymentProofUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};

export { updatePayment, getPaymentProof };
