import categoriesRepository from "./categories.repository.js";

const createCategory = async (req, res) => {
    try {
    const { name } = req.body

    const category = await categoriesRepository.addCategory(name)

    res.status(200).json({ status:"success", message: "category berhasil di buat", data: {
        category
    } })
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal mengambil data user' });
    } 
}

const getCategories = async (req, res) => {
    try {
        const categories = await categoriesRepository.getCategories()

        if (categories.length === 0) {
            return res.status(404).json({ message: "category belum tersedia" });
        }

        res.status(200).json({ data: { categories } })
        
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal mengambil data user' });
    }
}

const getCategoryById = async (req, res) =>{
    try {
    const { id } = req.params

    const category = await categoriesRepository.getCategoryById(id)

    if(!category) {
        res.status(404).json({ status: "fail", message: "category tidak tersedia" })
    }

    res.status(200).json({ message: "category ditemukan", data: {
        category: category
    } })

    } catch(error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal mengambil data user' });
    } 

}

const updateCategory = async (req, res) => {
    try {
    const { id } = req.params
    const { name } = req.body

    const categoryId = await categoriesRepository.getCategoryById(id)

    if(!categoryId) {
        res.status(404).json({ status: "fail", message: "category tidak tersedia" })
    }

    const category = await categoriesRepository.updateCategory(id, name)

    res.status(200).json({ status: "success", message: "data berhasil di update", data: {
        category: category.id
    } })

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal mengambil data user' });
    }
}

const deleteCategoryById = async (req, res) => {
    try {
    const { id } = req.params

    const categoryId = await categoriesRepository.getCategoryById(id)

    if(!categoryId) {
        res.status(404).json({ status: "fail", message: "category tidak tersedia" })
    }

    await categoriesRepository.deleteCategoryById(id)

    res.status(200).json({ status: "sueccess", message: "category berhasil di hapus" })
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal mengambil data user' });
    }
}

export  {
    createCategory,
    getCategories,
    getCategoryById,
    updateCategory,
    deleteCategoryById
}