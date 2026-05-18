import { Router } from "express";
import {
  createUser,
  loginUser,
  logoutUser,
  changePassword,
  getProfile,
  updateProfile,
  getAllUsers
} from "../users/users.controller.js";
import validate from "../middleware/validate.js";
import authMiddleware from "../middleware/authMiddleware.js";
import { loginUserSchema, registerUserSchema, updateProfileSchema } from "../users/users.shcema.js";

const userRoutes = Router();

userRoutes.get("/profile", authMiddleware([]), getProfile)
userRoutes.get("/data-user", authMiddleware([]), getAllUsers)
userRoutes.post("/", validate(registerUserSchema), createUser);
userRoutes.post("/login", validate(loginUserSchema), loginUser);
userRoutes.post("/logout", logoutUser);
userRoutes.patch("/change-password", authMiddleware([]), changePassword);  
userRoutes.patch("/profile", authMiddleware([], validate(updateProfileSchema)), updateProfile) 

export default userRoutes;
