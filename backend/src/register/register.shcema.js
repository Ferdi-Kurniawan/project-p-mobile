import Joi from "joi";

const registerUserSchema = {
  body: Joi.object({
    fullname: Joi.string().required(),
    username: Joi.string().required(),
    password: Joi.string().required()
  })
};

export {
    registerUserSchema
}