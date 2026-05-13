import express from "express";
import authMiddleware from "../middleware/authMiddleware.js";
import upload from "../config/storage.js";
import {
  updatePayment,
  getPaymentProof,
} from "../payment/payment.controller.js";
import { paymentSchema } from "../payment/payment.schema.js";
import validate from "../middleware/validate.js";

const routerPayment = express.Router();

routerPayment.post(
  "/:bookingId",
  authMiddleware([]),
  validate(paymentSchema),
  upload.single("payment_proof"),
  updatePayment,
);

routerPayment.get("/:bookingId/proof", authMiddleware([]), getPaymentProof);

export default routerPayment;
