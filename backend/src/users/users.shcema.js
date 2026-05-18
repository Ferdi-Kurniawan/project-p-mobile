import Joi from "joi";

const registerUserSchema = {
  body: Joi.object({
    fullname: Joi.string().required(),
    phone: Joi.string().max(13),
    email: Joi.string().required(),
    password: Joi.string().required()
  })
};

const loginUserSchema = {
  body: Joi.object({
    email: Joi.string().required(),
    password: Joi.string().required()
  })
}

const updateProfileSchema = {
  body:Joi.object({
    fullname: Joi.string().optional(),
    phone: Joi.string().optional(),
    email: Joi.string().email().optional()
  })
}

export {
    registerUserSchema,
    loginUserSchema,
    updateProfileSchema
}