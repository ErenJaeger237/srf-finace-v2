import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('admin123', 10);

  // 1. Upsert Organization
  const org = await prisma.organization.upsert({
    where: { id: 'default-org-id' }, // We use a fixed ID for the default org to make seeding reliable
    update: { name: 'Street Ride Organization' },
    create: {
      id: 'default-org-id',
      name: 'Street Ride Organization',
    },
  });

  // 2. Upsert Admin User
  await prisma.user.upsert({
    where: { email: 'admin@streetride.org' },
    update: {
      password,
      organizationId: org.id,
    },
    create: {
      name: 'Finance Manager',
      email: 'admin@streetride.org',
      password,
      role: Role.ADMIN,
      organizationId: org.id,
    },
  });

  // 3. Create Sample Cells if none exist
  const cellCount = await prisma.cell.count({ where: { organizationId: org.id } });
  if (cellCount === 0) {
    await prisma.cell.createMany({
      data: [
        { name: 'Logistics', budget: 10000, color: '#FF4500', icon: 'local_shipping', organizationId: org.id },
        { name: 'Marketing', budget: 10000, color: '#FF69B4', icon: 'campaign', organizationId: org.id },
        { name: 'Security', budget: 5000, color: '#008080', icon: 'security', organizationId: org.id },
      ],
    });
  }

  console.log('✅ Seed data updated successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
