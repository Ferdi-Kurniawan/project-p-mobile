import { Router } from "express";
import { createCategory, deleteCategoryById, getCategories, getCategoryById, updateCategory } from "../categories/categories.controller.js";
import { addCategory, putCategory } from "../categories/categories.schema.js";
import validate from '../middleware/validate.js';
import authMiddleware from "../middleware/authMiddleware.js";

const categoryRoutes = Router();

categoryRoutes.post('/', authMiddleware(['ADMIN']),validate(addCategory), createCategory)
categoryRoutes.get('/', getCategories)
categoryRoutes.get('/:id', getCategoryById)
categoryRoutes.put('/:id', authMiddleware(['ADMIN']), validate(putCategory), updateCategory)
categoryRoutes.delete('/:id', authMiddleware(['ADMIN']), deleteCategoryById)

export default categoryRoutes;

