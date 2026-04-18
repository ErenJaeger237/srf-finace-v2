import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { authenticate, isAdmin, AuthRequest } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

const cellSchema = z.object({
  name: z.string().min(2),
  budget: z.number().nonnegative(),
  icon: z.string().optional(),
  color: z.string().optional(),
});

// Get all cells for current organization
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const cells = await prisma.cell.findMany({
      where: { organizationId: req.user?.organizationId as string },
      include: {
        _count: {
          select: { expenses: true }
        }
      }
    });
    res.json(cells);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new cell (Admin Only)
router.post('/', authenticate, isAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const data = cellSchema.parse(req.body);
    const cell = await prisma.cell.create({
      data: {
        ...data,
        organizationId: req.user?.organizationId as string,
      },
    });
    res.status(201).json(cell);
  } catch (error) {
    if (error instanceof z.ZodError) return res.status(400).json({ errors: (error as any).errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Record cell income (Admin Only)
router.post('/:id/income', authenticate, isAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { amount } = z.object({ amount: z.number().positive() }).parse(req.body);
    const { id } = req.params;

    const cell = await prisma.cell.update({
      where: { id, organizationId: req.user?.organizationId as string },
      data: { income: { increment: amount } },
    });

    await prisma.auditLog.create({
      data: {
        organizationId: req.user?.organizationId as string,
        action: 'CELL_INCOME_RECORDED',
        details: `Income of ${amount} recorded for cell ${cell.name}`,
        performedBy: req.user?.email as string,
      }
    });

    res.json(cell);
  } catch (error) {
    if (error instanceof z.ZodError) return res.status(400).json({ errors: (error as any).errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
