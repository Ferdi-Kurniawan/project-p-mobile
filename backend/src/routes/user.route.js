import { Router } from 'express'
import { createUser } from '../register/register.controller.js';
import validate from '../middleware/validate.js';
import { registerUserSchema } from '../register/register.shcema.js';

const userRoutes = Router()

userRoutes.post('/', validate(registerUserSchema), createUser)

export default userRoutes;