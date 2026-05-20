import {
  createBooking,
  getBookings,
  getHistoryBookings,
  getHistoryBookingById,
  getBookingById,
  deleteBookingById,
  searchBooking,
} from "../booking/booking.controller.js";
import cartController from "../cart/cart.controller.js";
import authMiddleware from "../middleware/authMiddleware.js";
import express from "express";

const routerBooking = express.Router();

routerBooking.post("/", authMiddleware([]), createBooking);
routerBooking.get("/", authMiddleware([]), getBookings);
routerBooking.get("/history", authMiddleware(["ADMIN"]), getHistoryBookings);
routerBooking.get(
  "/history/:bookingId",
  authMiddleware(["ADMIN"]),
  getHistoryBookingById,
);
routerBooking.delete(
  "/history/:bookingId",
  authMiddleware(["ADMIN"]),
  deleteBookingById,
);

routerBooking.post("/add-item", authMiddleware([]), cartController.addItem);
routerBooking.get("/cart", authMiddleware([]), cartController.getCart);
routerBooking.post(
  "/remove-item",
  authMiddleware([]),
  cartController.removeItem,
);
routerBooking.post("/clear-cart", authMiddleware([]), cartController.clearCart);

routerBooking.get("/search", authMiddleware([]), searchBooking);

routerBooking.get("/:bookingId", authMiddleware([]), getBookingById);

export default routerBooking;
