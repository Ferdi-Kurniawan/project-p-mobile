import Joi from "joi";

const addSchemaProduct = {
    body: Joi.object({
        name: Joi.string().required(),
        price: Joi.number().min(0).required(),
        category_id: Joi.string().guid({ version: ['uuidv4'] }).required().messages({
        'string.empty': 'Category ID tidak boleh kosong.',
        'string.guid': 'Format Category ID tidak valid (harus UUID).',
        'any.required': 'Category ID wajib disertakan.'
        })
    })
}

const updateSchemaProduct = {
    body: Joi.object({
        name: Joi.string().required(),
        price: Joi.number().min(0).required(),
        category_id: Joi.string().guid({ version: ['uuidv4'] }).required().messages({
        'string.empty': 'Category ID tidak boleh kosong.',
        'string.guid': 'Format Category ID tidak valid (harus UUID).',
        'any.required': 'Category ID wajib disertakan.'
        })
    })
}

export {
    addSchemaProduct,
    updateSchemaProduct
}