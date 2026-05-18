import UserRepository from "./users.repository.js";
import PasswordHelper from "../helpers/bcrypt.js";
import setSession from "../helpers/session.js";

const createUser = async (req, res) => {
  try {
    const { fullname, phone, email, password } = req.body;

    // 1. Cek Email apakah sudah ada
    const checkEmail = await UserRepository.findByEmail(email);
    if (checkEmail) {
      return res.status(409).json({ status: "Email sudah digunakan" });
    }

    // 2. Cek Nomor HP apakah sudah ada
    const checkPhone = await UserRepository.findByPhone(phone);
    if (checkPhone) {
      return res.status(409).json({ status: "Nomor HP sudah terdaftar" });
    }

    // 3. Hash Password
    const passwordHash = await PasswordHelper.hashPassword(password);

    // 4. Simpan ke Database
    const users = await UserRepository.create({
      fullname,
      phone,
      email,
      password: passwordHash,
    });

    res.status(201).json({
      status: "success",
      message: "User berhasil dibuat",
      data: { users: users },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ status: "error", message: "Gagal membuat user" });
  }
};

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await UserRepository.findByEmail(email);

    if (!user) {
      return res
        .status(401)
        .json({ status: "fail", message: "Email atau password salah" });
    }

    const isPasswordMatch = await PasswordHelper.comparePassword(
      password,
      user.password,
    );

    if (!isPasswordMatch) {
      return res
        .status(401)
        .json({ status: "fail", message: "Email atau password salah" });
    }

    await setSession(req, user);

    return res.status(200).json({
      status: "success",
      message: "Login berhasil",
      data: {
        user: {
          id: user.id,
          fullname: user.fullname,
          phone: user.phone,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Gagal melakukan login" });
  }
};

const changePassword = async (req, res, next) => {
  const userId = req.session.user.id;

  const { oldPassword, newPassword, confirmNewPassword } = req.body;

  try {
    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({
        status: "fail",
        error: "Password baru dan konfirmasi password tidak cocok.",
      });
    }

    const currentUser = await UserRepository.getUserById(userId);
    if (!currentUser) {
      return res.status(404).json({
        status: "fail",
        error: "User tidak ditemukan.",
      });
    }

    const isOldPasswordValid = await PasswordHelper.comparePassword(
      oldPassword,
      currentUser.password,
    );

    if (!isOldPasswordValid) {
      return res.status(400).json({
        status: "fail",
        error: "Password lama yang Anda masukkan salah.",
      });
    }

    const newPasswordHash = await PasswordHelper.hashPassword(newPassword);

    await UserRepository.resetPassword(userId, newPasswordHash);

    return res.status(200).json({
      status: "success",
      message: "Password berhasil diperbarui.",
    });
  } catch (error) {
    return res.status(500).json({
      status: "fail",
      error: error.message,
    });
  }
};

const getProfile = async (req, res, next) => {
  const userId = req.session.user.id;

  try {
    const user = await UserRepository.getUserById(userId);

    if (!user) {
      return res.status(404).json({
        status: "fail",
        message: "User tidak ditemukan.",
      });
    }

    return res.status(200).json({
      status: "success",
      data: {
        user: {
          id: user.id,
          fullname: user.fullname,
          phone: user.phone,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: "fail",
      error: "terjadi kesalahan pada server.",
    });
  }
};

const updateProfile = async (req, res, next) => {
  const userId = req.session.user.id;

  const { fullname, phone, email } = req.body;

  try {
    if (!fullname && !phone && !email) {
      return res.status(400).json({
        status: "fail",
        error: "Tidak ada data yang dikirimkan untuk diperbarui.",
      });
    }

    const currentUser = await UserRepository.getUserById(userId);
    if (!currentUser) {
      return res
        .status(404)
        .json({ status: "fail", error: "User tidak ditemukan." });
    }

    const updateData = {};

    if (fullname) updateData.fullname = fullname;
    if (phone) updateData.phone = phone;

    if (email) {
      if (email !== currentUser.email) {
        const emailExists = await UserRepository.findByEmail(email);
        if (emailExists) {
          return res.status(409).json({
            status: "fail",
            error: "Email sudah terdaftar. Silakan gunakan email lain.",
          });
        }
      }
      updateData.email = email;
    }

    const updatedUser = await UserRepository.update(userId, updateData);

    return res.status(200).json({
      status: "success",
      message: "Profile berhasil diperbarui.",
      data: {
        user: {
          id: updatedUser.id,
          fullname: updatedUser.fullname,
          phone: updatedUser.phone,
          email: updatedUser.email,
          role: updatedUser.role,
        },
      },
    });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({
      status: "fail",
      error: "Terjadi kesalahan pada server",
    });
  }
};

const logoutUser = (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ status: "error", message: "Gagal logout" });
    }
    res.clearCookie("connect.sid");
    return res
      .status(200)
      .json({ status: "success", message: "Logout berhasil" });
  });
};

const getAllUsers = async (req, res) => {
  try {
    const users = await UserRepository.findAll();
    res.status(200).json({ status: "success", data: { users: users } });
  } catch (error) {
    res.status(500).json({ error: "Gagal mengambil data user" });
  }
};

export {
  createUser,
  loginUser,
  logoutUser,
  getAllUsers,
  changePassword,
  getProfile,
  updateProfile,
};
