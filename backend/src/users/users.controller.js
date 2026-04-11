import UserRepository from './UserRepository.js'
import PasswordHelper from '../helpers/bcrypt.js';

const createUser = async (req, res) => {
  try {
    const { fullname, phone, email, password } = req.body;

    // 1. Cek Email apakah sudah ada
    const checkEmail = await UserRepository.findByEmail(email);
    if(checkEmail) {
      return res.status(409).json({ status: "Email sudah digunakan" });
    }

    // 2. Cek Nomor HP apakah sudah ada
    const checkPhone = await UserRepository.findByPhone(phone);
    if(checkPhone) {
      return res.status(409).json({ status: "Nomor HP sudah terdaftar" });
    }

    // 3. Hash Password
    const passwordHash = await PasswordHelper.hashPassword(password);

    // 4. Simpan ke Database
    const users = await UserRepository.create({
      fullname,
      phone,
      email,
      password: passwordHash 
    });

    res.status(201).json({ 
      status: 'success',
      message: 'User berhasil dibuat', 
      data: { users } 
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({ status: 'error', message: 'Gagal membuat user' });
  }
};

const loginUser = async (req, res) => {
  const { email, password } = req.body;
  const user = await UserRepository.findByEmail(email);

  if(!user) {
    return res.status(401).json({ status: 'fail', message: 'Email atau password salah'});
  }

  const isPasswordMatch = await PasswordHelper.comparePassword(password, user.password);

  if (!isPasswordMatch) {
    return res.status(401).json({ status: 'fail', message: 'Email atau password salah' });
  }

  return res.status(200).json({
    status: 'success',
    message: 'Login berhasil',
    data: {
      user: {
        id: user.id,
        fullname: user.fullname,
        phone: user.phone,
        email: user.email
      }
    }
  });
}

const getAllUsers = async (req, res) => {
  try {
    const users = await UserRepository.findAll();
    res.status(200).json({ data: users });
  } catch (error) {
    res.status(500).json({ error: 'Gagal mengambil data user' });
  }
};

export { createUser, loginUser, getAllUsers };