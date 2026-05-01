import { createBooking } from "../booking/booking.controller.js";
import cartController from "../cart/cart.controller.js";
import authMiddleware from "../middleware/authMiddleware.js";
import express from "express";

const routerBooking = express.Router();

routerBooking.post("/create-booking", authMiddleware([]), createBooking);

routerBooking.post("/add-item", authMiddleware([]), cartController.addItem);

routerBooking.get("/cart/:userId", authMiddleware([]), cartController.getCart);

routerBooking.post(
  "/remove-item",
  authMiddleware([]),
  cartController.removeItem,
);

routerBooking.post("/clear-cart", authMiddleware([]), cartController.clearCart);

export default routerBooking;
