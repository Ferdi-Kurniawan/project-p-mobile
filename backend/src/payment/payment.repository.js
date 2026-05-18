import prisma from "../config/database.js";

class PaymentRepository {
  constructor() {
    this._prisma = prisma;
  }

  async updatePaymentProof(
    bookingId,
    userId,
    paymentMethod,
    paymentProofFilename,
  ) {
    return await this._prisma.booking.update({
      where: {
        id: bookingId,
        user_id: userId,
      },
      data: {
        payment_method: paymentMethod,
        payment_proof: paymentProofFilename,
        paidAt: new Date(),
        status: "PENDING_VERIFICATION",
      },
      include: { items: true, user: true },
    });
  }

  async verifyPayment(bookingId) {
    return await this._prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: "PAID",
      },
      include: {
        user: true,
        items: {
          include: { product: true },
        },
      },
    });
  }

  async cancelPayment(bookingId) {
    return await this._prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: "CANCELLED",
      },
      include: {
        user: true,
        items: {
          include: { product: true },
        },
      },
    });
  }

  async checkInTicket(ticketCode) {
    return await this._prisma.booking.update({
      where: { ticket_code: ticketCode },
      data: {
        is_checked_in: true,
        checked_in_at: new Date(), // Catat waktu saat ini
      },
    });
  }
}

export default new PaymentRepository();
