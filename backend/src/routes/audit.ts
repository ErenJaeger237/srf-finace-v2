import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticate } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

// Get audit logs for current organization
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const logs = await prisma.auditLog.findMany({
      where: { organizationId: req.user?.organizationId as string },
      orderBy: { timestamp: 'desc' },
      take: 50, // Limit to recent 50 logs
    });
    res.json(logs);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
