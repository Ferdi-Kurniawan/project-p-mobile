import bcrypt from 'bcrypt';

const PasswordHelper = {
  // Fungsi untuk mengacak password (dipakai saat Register)
  async hashPassword(plainPassword) {
    const saltRounds = 10;
    return await bcrypt.hash(plainPassword, saltRounds);
  },

  // Fungsi untuk mencocokkan password (dipakai saat Login)
  async comparePassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }
};

export default PasswordHelper;