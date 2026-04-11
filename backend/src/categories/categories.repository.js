import prisma from "../config/database.js";

class CategoriesRepository {
    constructor() {
       this._prisma = prisma;
    }

    async addCategory(name) {
        return await this._prisma.category.create({
            data: { name: name }
        })
    }

    async updateCategory(categoryId, name) {
        return await this._prisma.category.update({
            where: { id: categoryId },
            data: {
                name: name
            }
        })
    }

    async getCategories() {
        return await this._prisma.category.findMany({
            select: {
                id: true,
                name: true
            }
        })
    }

    async getCategoryById(categoryId) {
        return await this._prisma.category.findUnique({
            where: { id: categoryId }
        })
    }

    async deleteCategoryById(categoryId) {
        return await this._prisma.category.delete({
            where: { id: categoryId }
        })
    }
} 

export default new CategoriesRepository();