import Joi from "joi";

const registerUserSchema = {
  body: Joi.object({
    fullname: Joi.string().required(),
    phone: Joi.string().max(13),
    email: Joi.string().required(),
    password: Joi.string().required()
  })
};

export {
    registerUserSchema
}