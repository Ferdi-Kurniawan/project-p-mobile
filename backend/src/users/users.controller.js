import UserRepository from './users.repository.js'
import PasswordHelper from '../helpers/bcrypt.js';
import setSession from '../helpers/session.js';

const createUser = async (req, res) => {
  try {
    const { fullname, phone, email, password } = req.body;

    const checkEmail = await UserRepository.findByEmail(email);

    if(checkEmail) {
      return res.status(409).json({ status: "fail", message: "Email Sudah Di Gunakan" })
    }

    const passwordHash = await PasswordHelper.hashPassword(password)

    // Panggil fungsi dari repository, BUKAN dari prisma langsung
    const users = await UserRepository.create({
      fullname,
      phone,
      email,
      password: passwordHash 
    });


    res.status(200).json({ message: 'user berhasil dibuat', data: {
      users
    } });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: 'Gagal membuat user' });
  }
};

const loginUser = async (req, res) => {
  try {
  const { email, password } = req.body;

  const user = await UserRepository.findByEmail(email);

  if(!user) {
    return res.status(401).json({ status: 'fail', message: 'email atau password salah'})
  }

  const isPasswordMatch = await PasswordHelper.comparePassword(password, user.password);

  if (!isPasswordMatch) {
      return res.status(401).json({
        status: 'fail',
        message: 'email atau password salah'
      });
  }

  await setSession(req, user);

  return res.status(200).json({
      status: 'success',
      message: 'login berhasil',
      data: {
        user: {
          id: user.id,
          fullname: user.fullname,
          phone: user.phone,
          email: user.email
        }
      }
  })
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal melakukan login' });
  }
}

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
    loginUser,
    getAllUsers
}