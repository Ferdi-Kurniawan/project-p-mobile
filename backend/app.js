import 'dotenv/config';
import express from 'express'; 
import cors from 'cors';
import userRoutes from './src/routes/user.route.js';

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors)

app.use('/users', userRoutes);

app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    
    return res.status(400).json({
      status: 'error',
      message: 'Format JSON yang Anda kirimkan tidak valid (Syntax Error).',
    });
  }

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    status: 'error',
    message: err.message || 'Terjadi kesalahan pada server (Internal Server Error)'
  });
});

const port = process.env.PORT;
const host = process.env.HOST;

app.listen(port, () => {
    console.log(`http://${host}:${port}/`)
})