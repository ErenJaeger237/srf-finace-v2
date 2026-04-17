import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('admin123', 10);

  // 1. Create Organization
  const org = await prisma.organization.create({
    data: {
      name: 'Street Ride Organization',
    },
  });

  // 2. Create Admin User
  await prisma.user.create({
    data: {
      name: 'Finance Manager',
      email: 'admin@streetride.org',
      password,
      role: Role.ADMIN,
      organizationId: org.id,
    },
  });

  // 3. Create Sample Cells
  await prisma.cell.createMany({
    data: [
      { name: 'Logistics', budget: 10000, color: '#FF4500', icon: 'local_shipping', organizationId: org.id },
      { name: 'Marketing', budget: 10000, color: '#FF69B4', icon: 'campaign', organizationId: org.id },
      { name: 'Security', budget: 5000, color: '#008080', icon: 'security', organizationId: org.id },
    ],
  });

  console.log('✅ Seed data created successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
