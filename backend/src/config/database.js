// src/config/database.js
import 'dotenv/config';

import pg from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';

// 1. Import PrismaClient dari folder yang sudah kita pindahkan
import { PrismaClient } from '../generated/prisma/index.js'; 

const { Pool } = pg;

// 2. Ambil URL dari .env
const connectionString = process.env.DATABASE_URL;

// 3. Buat koneksi pool menggunakan driver 'pg'
const pool = new Pool({ connectionString });

// 4. Pasangkan pool tersebut ke Prisma Adapter
const adapter = new PrismaPg(pool);

// 5. Inisialisasi Prisma Client (WAJIB memasukkan { adapter } di Prisma v7+)
const prisma = new PrismaClient({ adapter });

export default prisma;