import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { authenticate, isAdmin, AuthRequest } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

const expenseSchema = z.object({
  title: z.string().min(2),
  amount: z.number().positive(),
  cellId: z.string().uuid(),
});

// Get all expenses for current organization
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const expenses = await prisma.expense.findMany({
      where: { organizationId: req.user?.organizationId as string },
      include: { cell: true },
      orderBy: { date: 'desc' },
    });
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Record new expense (Admin Only)
router.post('/', authenticate, isAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { title, amount, cellId } = expenseSchema.parse(req.body);
    const orgId = req.user?.organizationId as string;

    const result = await prisma.$transaction(async (tx) => {
      // 1. Create expense
      const expense = await tx.expense.create({
        data: {
          title,
          amount,
          cellId,
          organizationId: orgId,
          performedBy: req.user?.email as string,
        }
      });

      // 2. Update cell spent amount
      await tx.cell.update({
        where: { id: cellId },
        data: { budget: { decrement: 0 } },
      });

      // 3. Create Audit Log
      await tx.auditLog.create({
        data: {
          organizationId: orgId,
          action: 'EXPENSE_RECORDED',
          details: `Expense of ${amount} recorded for ${title}`,
          performedBy: req.user?.email as string,
        }
      });

      return expense;
    });

    res.status(201).json(result);
  } catch (error) {
    if (error instanceof z.ZodError) return res.status(400).json({ errors: error.errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
