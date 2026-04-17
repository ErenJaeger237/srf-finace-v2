import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { AuthRequest, authenticate, isAdmin } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

const cellSchema = z.object({
  name: z.string().min(2),
  budget: z.number().min(0),
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
    if (error instanceof z.ZodError) return res.status(400).json({ error: error.errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
