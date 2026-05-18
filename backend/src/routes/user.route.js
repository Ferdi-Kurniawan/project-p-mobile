import { Router } from "express";
import {
  createUser,
  loginUser,
  logoutUser,
  changePassword,
} from "../users/users.controller.js";
import validate from "../middleware/validate.js";
import authMiddleware from "../middleware/authMiddleware.js";
import { loginUserSchema, registerUserSchema } from "../users/users.shcema.js";

const userRoutes = Router();

userRoutes.post("/", validate(registerUserSchema), createUser);
userRoutes.post("/login", validate(loginUserSchema), loginUser);
userRoutes.post("/logout", logoutUser);
userRoutes.patch("/change-password", authMiddleware([]), changePassword);   

export default userRoutes;
