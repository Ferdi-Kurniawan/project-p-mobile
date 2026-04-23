import prisma from "../config/database.js";

class BookingRepository {
  async createBooking(userId, startDate, endDate, items) {
    const calculatedTotalPrice = items.reduce((total, item) => {
      return total + item.price * item.quantity;
    }, 0);

    return await prisma.booking.create({
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

      include: {
        items: true,
      },
    });
  }
}
