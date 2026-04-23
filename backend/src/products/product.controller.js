import productRepository from "./product.repository.js";
import categoriesRepository from "../categories/categories.repository.js";

const createProduct = async (req, res) => {
  try {
    const { category_id, name, price, stock } = req.body;

    const existingCategory =
      await categoriesRepository.getCategoryById(category_id);

    if (!existingCategory) {
      return res
        .status(404)
        .json({ status: "fail", message: "category tidak di temukan" });
    }

    const product = await productRepository.addProduct(
      {
        name: name,
        price: price,
        stock: stock,
      },
      category_id,
    );

    return res.status(200).json({
      message: "data berhasil di buat",
      data: {
        product,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: "terjadi kesalahan pada server" });
  }
};

const getAllProduct = async (req, res) => {
  const product = await productRepository.getAllProduct();

  if (product.length === 0) {
    return res.status(404).json({
      status: "fail",
      message: "product tidak di temukan",
    });
  }

  return res.status(200).json({
    status: "success",
    data: {
      product,
    },
  });
};

const getProductById = async (req, res) => {
  const { productId } = req.params;

  const product = await productRepository.getProductById(productId);

  if (!product) {
    return res.status(404).json({
      status: "fail",
      message: "product tidak ditemukan",
    });
  }

  if (product.stock === 0) {
    return res.status(200).json({
      status: "success",
      message: "product habis",
      data: {
        product,
      },
    });
  }

  return res.status(200).json({
    status: "success",
    data: {
      product,
    },
  });
};

const updateProductById = async (req, res) => {
  try {
    const { productId } = req.params;

    const existingProduct = await productRepository.getProductById(productId);

    if (!existingProduct) {
      return res.status(404).json({
        status: "fail",
        message: "product tidak ditemukan",
      });
    }

    const { category_id, name, price, stock } = req.body;

    const existingCategory =
      await categoriesRepository.getCategoryById(category_id);

    if (!existingCategory) {
      return res.status(404).json({
        status: "fail",
        message: "category tidak ditemukan",
      });
    }

    await productRepository.updateProductById(productId, category_id, {
      name,
      price,
      stock,
    });

    return res.status(200).json({
      status: "success",
      message: "berhasil update product",
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "terjadi kesalahan pada server" });
  }
};

const deleteProductById = async (req, res) => {
  try {
    const { productId } = req.params;

    const existingProduct = await productRepository.getProductById(productId);

    if (!existingProduct) {
      return res.status(404).json({
        status: "fail",
        message: "product tidak ditemukan",
      });
    }

    const product = await productRepository.deleteProductById(productId);

    return res.status(200).json({
      status: "success",
      message: "product berhasil di hapus",
    });
  } catch (error) {
    return res.status(500).json({ message: "kesalahan internal server" });
  }
};

export {
  createProduct,
  getAllProduct,
  getProductById,
  updateProductById,
  deleteProductById,
};
