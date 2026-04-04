import Joi from 'joi';

const validate = (schema) => (req, res, next) => {
  const validSchema = Joi.object(schema);
  const objectToValidate = {};

  if (schema.body) objectToValidate.body = req.body;
  if (schema.query) objectToValidate.query = req.query;
  if (schema.params) objectToValidate.params = req.params;

  const { value, error } = validSchema.validate(objectToValidate, {
    abortEarly: false, 
    stripUnknown: true 
  });

  // Jika ada error, kembalikan response 400 Bad Request
  if (error) {
    console.log(error)
    return res.status(400).json({ 
      status: 'error',
      message: 'Data yang anda masukan tidak valid' 
    });
  }

  // Menggabungkan kembali data yang sudah divalidasi/dibersihkan ke object request
  Object.assign(req, value);

  return next();
};

export default validate;