import express from "express";
import authMiddleware from "../middleware/authMiddleware.js";
import upload from "../config/storage.js";
import {
  updatePayment,
  getPaymentProof,
  verifyPaymentAdmin,
  cancelPaymentAdmin,
  checkInTicket
} from "../payment/payment.controller.js";
import {
  paymentSchema,
  cancelPaymentSchema,
} from "../payment/payment.schema.js";
import validate from "../middleware/validate.js";

const routerPayment = express.Router();

routerPayment.post(
  "/:bookingId",
  authMiddleware([]),
  validate(paymentSchema),
  upload.single("payment_proof"),
  updatePayment,
);

routerPayment.patch(
  "/verify/:bookingId",
  authMiddleware(["ADMIN"]),
  verifyPaymentAdmin,
);

routerPayment.patch(
  "/cancel/:bookingId",
  authMiddleware(["ADMIN"]),
  validate(cancelPaymentSchema),
  cancelPaymentAdmin,
);

routerPayment.patch(
  "/check-in/:ticketCode",
  authMiddleware(["ADMIN"]),
  checkInTicket
)

routerPayment.get("/:bookingId/proof", authMiddleware([]), getPaymentProof);

export default routerPayment;
