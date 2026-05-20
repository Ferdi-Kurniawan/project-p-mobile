import PaymentRepository from "./payment.repository.js";
import bookingRepository from "../booking/booking.repository.js";
import qrcode from "qrcode";
import { sendEmail } from "../config/nodemailer.js";

const updatePayment = async (req, res, next) => {
  try {
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
    const booking = await PaymentRepository.updatePaymentProof(
      bookingId,
      userId,
      payment_method,
      filename,
    );

    const emailSubject = `Pembayaran Sedang Diproses - Order #${booking.id}`;
    const emailHtml = `
      <h3>Halo, ${booking.user.fullname}</h3>
      <p>Terima kasih telah melakukan pembayaran. Bukti pembayaran Anda telah kami terima dan saat ini <strong>sedang dalam proses verifikasi oleh Admin</strong>.</p>
      <p>Kami akan mengabari Anda kembali melalui email jika pembayaran sudah divalidasi.</p>
    `;

    sendEmail(booking.user.email, emailSubject, emailHtml);

    res.status(200).json({
      status: "success",
      message: "Pembayaran berhasil dikonfirmasi",
      data: { booking: booking },
    });
  } catch (error) {
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

const verifyPaymentAdmin = async (req, res) => {
  const { bookingId } = req.params;

  try {
    const exsitingBooking = await bookingRepository.getBookingById(bookingId);

    if (!exsitingBooking) {
      return res
        .status(404)
        .json({ status: "fail", error: "Booking tidak ditemukan." });
    }

    const booking = await PaymentRepository.verifyPayment(bookingId);

    // 2. Format daftar pesanan untuk dimasukkan ke email
    let itemsHtml = "<ul>";
    booking.items.forEach((item) => {
      itemsHtml += `<li>${item.product.name} - ${item.quantity}x (Rp ${item.price})</li>`;
    });
    itemsHtml += "</ul>";

    const qrCodeImage = await qrcode.toDataURL(booking.ticket_code);

    const emailSubject = `Pembayaran Berhasil! Ini Tiket Anda - Order #${booking.id}`;
    const emailHtml = `
      <h3>Halo, ${booking.user.fullname}</h3>
      <p>Kabar gembira! Pembayaran Anda telah <strong>berhasil diverifikasi</strong>.</p>
      <br>
      <div style="background-color: #f4f4f4; padding: 15px; border-radius: 8px; text-align: center;">
        <p>Tunjukkan QR Code ini kepada petugas saat kedatangan:</p>
        
        <!-- Panggil gambar menggunakan CID -->
        <img src="cid:tiket-qrcode" alt="Ticket QR Code" style="width: 200px; height: 200px;" />
        
        <br>
        <p>Atau sebutkan kode: <strong>${booking.ticket_code}</strong></p>
      </div>
    `;

    const attachments = [
      {
        filename: "qrcode.png",
        path: qrCodeImage,
        cid: "tiket-qrcode",
      },
    ];

    sendEmail(booking.user.email, emailSubject, emailHtml, attachments);

    return res.status(200).json({
      status: "success",
      message: "Pembayaran berhasil diverifikasi dan email telah dikirim.",
      data: { booking: booking },
    });
  } catch (error) {
    return res.status(500).json({ status: "fail", error: error.message });
  }
};

const cancelPaymentAdmin = async (req, res) => {
  const { bookingId } = req.params;

  const { reason } = req.body;

  try {
    const existingBooking = await bookingRepository.getBookingById(bookingId);

    if (!existingBooking) {
      return res
        .status(404)
        .json({ status: "fail", error: "Booking tidak ditemukan." });
    }

    const booking = await PaymentRepository.cancelPayment(bookingId);

    const emailSubject = `Pemberitahuan: Pembayaran Gagal Diverifikasi - Order #${booking.id}`;
    let emailHtml = `
      <h3>Halo, ${booking.user.fullname},</h3>
      <p>Mohon maaf, kami menginformasikan bahwa pembayaran Anda untuk pesanan <strong>#${booking.id}</strong> <strong>gagal diverifikasi</strong> dan pesanan terpaksa dibatalkan.</p>
    `;

    if (reason) {
      emailHtml += `
        <div style="background-color: #ffe6e6; padding: 10px; border-left: 4px solid #ff4d4d; margin-bottom: 15px;">
          <p style="margin: 0;"><strong>Alasan Penolakan:</strong> ${reason}</p>
        </div>
      `;
    }

    emailHtml += `
      <p>Silakan periksa kembali detail pembayaran Anda atau lakukan pemesanan ulang melalui sistem kami.</p>
      <p>Jika Anda merasa ini adalah sebuah kesalahan atau saldo Anda sudah terpotong, silakan hubungi tim dukungan pelanggan kami dengan melampirkan bukti transaksi.</p>
      <br>
      <p>Terima kasih,</p>
      <p>Tim Admin</p>
    `;

    sendEmail(booking.user.email, emailSubject, emailHtml);

    return res.status(200).json({
      status: "success",
      message:
        "Pembayaran berhasil dibatalkan dan email pemberitahuan telah dikirim ke user.",
    });
  } catch (error) {
    return res.status(500).json({ status: "fail", error: error.message });
  }
};

const checkInTicket = async (req, res) => {
  // Tiket code didapat dari hasil scan kamera (dikirim via body oleh aplikasi scanner admin)
  const { ticketCode } = req.params;

  if (!ticketCode) {
    return res
      .status(400)
      .json({ status: "fail", error: "Kode tiket wajib disertakan." });
  }

  try {
    // 1. Cari booking berdasarkan ticket_code
    const booking = await bookingRepository.checkTiketCode(ticketCode);

    // 2. Validasi apakah tiket ada
    if (!booking) {
      return res.status(404).json({
        status: "fail",
        error: "Tiket tidak valid atau tidak ditemukan.",
      });
    }

    // 3. Validasi apakah status tiket sudah PAID
    if (booking.status !== "PAID") {
      return res.status(400).json({
        status: "fail",
        error: `Tiket tidak bisa digunakan. Status saat ini: ${booking.status}`,
      });
    }

    // 4. Validasi apakah tiket sudah pernah di-scan sebelumnya (mencegah tiket ganda)
    if (booking.is_checked_in) {
      return res.status(400).json({
        status: "fail",
        error: `Tiket sudah digunakan pada ${booking.checked_in_at.toLocaleString()}`,
      });
    }

    // 5. Update status check-in di database
    const updatedBooking = await PaymentRepository.checkInTicket(ticketCode);

    const invoice = res.status(200).json({
      status: "success",
      message: `Check-in berhasil untuk tamu: ${booking.user.fullname}`,
      data: {
        ticket_code: updatedBooking.ticket_code,
        check_in_time: updatedBooking.checked_in_at,
      },

    });

      console.log(invoice)

  } catch (error) {
    return res.status(500).json({ status: "fail", error: error.message });
  }
};

export {
  updatePayment,
  getPaymentProof,
  verifyPaymentAdmin,
  cancelPaymentAdmin,
  checkInTicket,
};
