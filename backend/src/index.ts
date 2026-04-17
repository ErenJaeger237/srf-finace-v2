import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

import authRoutes from './routes/auth';
import cellRoutes from './routes/cells';
import expenseRoutes from './routes/expenses';
import contributionRoutes from './routes/contributions';
import auditRoutes from './routes/audit';
import memberRoutes from './routes/members';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/cells', cellRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/contributions', contributionRoutes);
app.use('/api/audit', auditRoutes);
app.use('/api/members', memberRoutes);

// Health Check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'active', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`🚀 SRFM API running on http://localhost:${PORT}`);
});
