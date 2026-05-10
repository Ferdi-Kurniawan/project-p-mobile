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
        status: "PAID",
      },
      include: { items: true },
    });
  }
}

export default new PaymentRepository();
