const setSession = (req, user) => {
  return new Promise((resolve, reject) => {
    req.session.user = {
      id: user.id,
      fullname: user.fullname,
      email: user.email,
      role: user.role
    };

    // Kita paksa simpan sekarang dan tunggu hasilnya
    req.session.save((err) => {
      if (err) {
        console.error("Gagal menyimpan session:", err);
        reject(err);
      } else {
        resolve();
      }
    });
  });
}

export default setSession;


