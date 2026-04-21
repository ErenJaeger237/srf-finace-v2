import { Router } from 'express';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import { AuthRequest, authenticate, isAdmin } from '../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

const memberSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(4),
});

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
      },
      orderBy: { name: 'asc' }
    });
    res.json(members);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new member (Admin Only)
router.post('/', authenticate, isAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { name, email, password } = memberSchema.parse(req.body);
    const orgId = req.user?.organizationId as string;

    // Check if email exists
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return res.status(400).json({ error: 'Email already registered' });

    const hashedPassword = await bcrypt.hash(password, 10);

    const member = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
        role: 'MEMBER',
        organizationId: orgId,
      },
      select: { id: true, name: true, email: true }
    });

    await prisma.auditLog.create({
      data: {
        organizationId: orgId,
        action: 'MEMBER_CREATED',
        details: `New member ${name} (${email}) added to organization`,
        performedBy: req.user?.email as string,
      }
    });

    res.status(201).json(member);
  } catch (error) {
    if (error instanceof z.ZodError) return res.status(400).json({ errors: (error as any).errors });
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;

