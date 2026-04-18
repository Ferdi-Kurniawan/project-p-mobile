import { Router } from "express";
import { createProduct, deleteProductById, getAllProduct, getProductById, updateProductById } from "../products/product.controller.js";
import { addSchemaProduct, updateSchemaProduct } from "../products/product.schema.js";
import validate from "../middleware/validate.js";
import authMiddleware from "../middleware/authMiddleware.js";

const routerProduct = Router()

routerProduct.post('/', authMiddleware(['ADMIN']),validate(addSchemaProduct), createProduct)
routerProduct.get('/', getAllProduct)
routerProduct.get('/:productId', getProductById)
routerProduct.put('/:productId', authMiddleware(['ADMIN']), validate(updateSchemaProduct), updateProductById)
routerProduct.delete('/:productId', authMiddleware(['ADMIN']), deleteProductById)

export default routerProduct