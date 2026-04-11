import Joi from "joi";

const addCategory = {
  body: Joi.object({
    name: Joi.string().required()
  })
};

const putCategory = {
  body: Joi.object({
    name: Joi.string().required()
  })
};

export { addCategory, putCategory }