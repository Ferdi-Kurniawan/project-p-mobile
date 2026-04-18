import 'dotenv/config';
import express from 'express'; 
import cors from 'cors';
import session from 'express-session';
import userRoutes from './src/routes/user.route.js';
import categoryRoutes from './src/routes/category.route.js';
<<<<<<< HEAD
=======
import routerProduct from './src/routes/product.routes.js';
>>>>>>> ff0ec1be46f7f2f76a617c854703995958485486

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(session({
  secret: process.env.SECRET_SESSION,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false,
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000
  }
}))

app.use('/users', userRoutes);
app.use('/category', categoryRoutes);
<<<<<<< HEAD
=======
app.use('/product', routerProduct)
>>>>>>> ff0ec1be46f7f2f76a617c854703995958485486

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


app.listen(port, '0.0.0.0', () => {
    console.log(`http://${host}:${port}/`)
})