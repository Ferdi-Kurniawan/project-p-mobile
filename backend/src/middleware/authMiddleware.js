const authMiddleware = (roles = []) => {
  return (req, res, next) => {
    // 1. Cek apakah user sudah login
    if (!req.session || !req.session.user) {
      return res.status(401).json({ status: 'fail', message: "Unauthorized: Silakan login" });
    }

    // 2. Jika roles dikosongkan, berarti semua yang login bisa masuk
    if (roles.length === 0) {
      return next();
    }

    // 3. Cek apakah role user ada di dalam daftar role yang diizinkan
    // Asumsi: saat login, Anda menyimpan data user seperti { id: 1, role: 'admin' } di session
    if (roles.includes(req.session.user.role)) {
      next();
    } else {
      res.status(403).json({ 
        status: 'fail',
        message: "Forbidden: Anda tidak memiliki akses ke resource ini" 
      });
    }
  };
};

export default authMiddleware;