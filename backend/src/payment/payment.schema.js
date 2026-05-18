import Joi from "joi";

export const paymentSchema = {
  body: Joi.object({
    payment_method: Joi.string().required(),
    file: Joi.object({
      filename: Joi.string().required(),
      mimetype: Joi.string()
        .valid("image/jpeg", "image/png", "image/jpg", "image/webp")
        .required(),
    })
      .required()
      .messages({
        "any.required": "Bukti pembayaran (file gambar) wajib diunggah.",
      }),
  }),
};

export const cancelPaymentSchema = {
  body: Joi.object({
    reason: Joi.string().required(),
  }),
};
