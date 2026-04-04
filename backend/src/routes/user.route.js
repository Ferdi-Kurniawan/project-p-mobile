import { Router } from 'express'
import { createUser, loginUser } from '../users/users.controller.js';
import validate from '../middleware/validate.js';
import { loginUserSchema, registerUserSchema } from '../users/users.shcema.js';


const userRoutes = Router()

userRoutes.post('/', validate(registerUserSchema), createUser)
userRoutes.post('/login', validate(loginUserSchema), loginUser)

export default userRoutes;