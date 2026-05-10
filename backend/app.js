import "dotenv/config";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import cors from "cors";
import session from "express-session";
import userRoutes from "./src/routes/user.route.js";
import categoryRoutes from "./src/routes/category.route.js";
import routerProduct from "./src/routes/product.routes.js";
import routerBooking from "./src/routes/booking.routes.js";
import routerPayment from "./src/routes/payment.route.js";
import upload from "./src/config/storage.js";

const app = express();

const filename = fileURLToPath(import.meta.url);
const dirname = path.dirname(filename);

const invoiceDirectory = path.join(dirname, "src/uploads/payment");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/payment", express.static(invoiceDirectory));

app.set("trust proxy", 1);

app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);

app.use(
  session({
    secret: process.env.SECRET_SESSION,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: false,
      httpOnly: true,
      sameSite: "none",
      maxAge: 24 * 60 * 60 * 1000,
    },
  }),
);

app.use("/users", userRoutes);
app.use("/category", categoryRoutes);
app.use("/product", routerProduct);
app.use("/booking", routerBooking);
app.use("/payment", routerPayment);

app.use((err, req, res, next) => {
  if (err.message === "INVALID_FILE_TYPE") {
    return res.status(400).json({
      status: "error",
      message:
        "Format file tidak valid! Hanya diperbolehkan upload gambar (JPG, PNG, WEBP).",
    });
  }

  if (err.code === "LIMIT_FILE_SIZE") {
    return res.status(400).json({
      status: "error",
      message: "Ukuran file terlalu besar! Maksimal 5MB.",
    });
  }

  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    return res.status(400).json({
      status: "error",
      message: "Format JSON yang Anda kirimkan tidak valid (Syntax Error).",
    });
  }

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    status: "error",
    message:
      err.message || "Terjadi kesalahan pada server (Internal Server Error)",
  });
});

const port = process.env.PORT;
const host = process.env.HOST;

app.listen(port, "0.0.0.0", () => {
  console.log(`http://${host}:${port}/`);
});
