import prisma from "../config/database.js";

class BookingRepository {
  constructor() {
    this._prisma = prisma;
  }

  async createBookingWithTransaction(
    userId,
    startDate,
    endDate,
    calculatedTotalPrice,
    items,
  ) {
    return await this._prisma.$transaction(async (tx) => {
      for (const item of items) {
        const updateResult = await tx.product.updateMany({
          where: {
            id: item.productId,
            stock: { gte: item.quantity },
          },
          data: {
            stock: { decrement: item.quantity },
          },
        });

        if (updateResult.count === 0) {
          throw new Error(`INSUFFICIENT_STOCK_${item.productId}`);
        }
      }

      return await tx.booking.create({
        data: {
          user_id: userId,
          start_date: new Date(startDate),
          end_date: new Date(endDate),
          total_price: calculatedTotalPrice,
          items: {
            create: items.map((item) => ({
              product_id: item.productId,
              quantity: item.quantity,
              price: item.price,
            })),
          },
        },
        include: { items: true },
      });
    });
  }
}

export default new BookingRepository();
