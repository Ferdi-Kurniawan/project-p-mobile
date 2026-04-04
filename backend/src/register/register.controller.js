import UserRepository from './register.repository.js'
import PasswordHelper from '../helpers/bcrypt.js';

const createUser = async (req, res) => {
  try {
    const { fullname, username, password } = req.body;

    const checkUsername = await UserRepository.findByUsername(username);

    if(checkUsername) {
      return res.status(409).json({ status: "fail", message: "Username Sudah Di Gunakan" })
    }

    const passwordHash = await PasswordHelper.hashPassword(password)

    // Panggil fungsi dari repository, BUKAN dari prisma langsung
    const users = await UserRepository.create({
      fullname,
      username,
      password: passwordHash 
    });


    res.status(200).json({ message: 'User berhasil dibuat', data: {
      users
    } });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: 'Gagal membuat user' });
  }
};

const getAllUsers = async (req, res) => {
  try {
    const users = await UserRepository.findAll();
    res.status(200).json({ data: users });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil data user' });
  }
};

export  {
    createUser,
    getAllUsers
}