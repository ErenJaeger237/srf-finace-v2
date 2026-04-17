import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { authenticate, isAdmin, AuthRequest } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

const contributionSchema = z.object({
  userId: z.string().uuid(),
  amount: z.number().positive(),
});

// Get all contributions for current organization
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const contributions = await prisma.contribution.findMany({
      where: { organizationId: req.user?.organizationId as string },
      include: { user: { select: { name: true, email: true } } },
      orderBy: { date: 'desc' },
    });
    res.json(contributions);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Record new contribution (Admin Only)
router.post('/', authenticate, isAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { userId, amount } = contributionSchema.parse(req.body);
    const orgId = req.user?.organizationId as string;

    const contribution = await prisma.contribution.create({
      data: {
        userId,
        amount,
        organizationId: orgId,
      },
      include: { user: { select: { name: true } } }
    });

    await prisma.auditLog.create({
      data: {
        organizationId: orgId,
        action: 'CONTRIBUTION_ADDED',
        details: `Contribution of ${amount} added for member ${contribution.user.name}`,
        performedBy: req.user?.email as string,
      }
    });

    res.status(201).json(contribution);
  } catch (error) {
    if (error instanceof z.ZodError) return res.status(400).json({ errors: (error as any).errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
