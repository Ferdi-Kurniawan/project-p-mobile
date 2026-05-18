import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER, // contoh: emailkamu@gmail.com
    pass: process.env.EMAIL_PASS, // App Password dari Google Account
  },
});

const sendEmail = async (to, subject, htmlContent, attachments = []) => {
  try {
    await transporter.sendMail({
      from: `"Sistem Booking" <${process.env.EMAIL_USER}>`,
      to: to,
      subject: subject,
      html: htmlContent,
      attachments: attachments,
    });
    console.log(`Email berhasil dikirim ke ${to}`);
  } catch (error) {
    console.error("Gagal mengirim email:", error);
  }
};

export { sendEmail };
