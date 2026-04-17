import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticate } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

// Get all members for current organization
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const members = await prisma.user.findMany({
      where: { 
        organizationId: req.user?.organizationId as string,
        role: 'MEMBER'
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
      }
    });
    res.json(members);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
