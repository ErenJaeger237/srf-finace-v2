# Street Ride Finance Manager (SRFM)

## Overview
SRFM is a mobile-first financial management platform built for a 14-member organization managing riding festivals. It provides transparent financial tracking, budget management per cell, and real-time analytics.

## Tech Stack
- **Frontend:** Flutter (Mobile App, Android 6+/iOS 17+)
- **Backend:** Node.js (TypeScript/Express)
- **Database:** MySQL (PlanetScale/Render)
- **State:** Riverpod
- **Auth:** JWT/Bcrypt

## Prerequisites
1. **Flutter SDK:** Version 3.41.6+
2. **Node.js:** Version 20.x+
3. **Database:** Access to a MySQL instance (e.g., PlanetScale or local).
4. **Environment:** `.env` file in the `backend/` directory.

## Getting Started

### 1. Backend Setup
```bash
cd backend
npm install
# Configure your .env file
cp .env.example .env
npx prisma db push
npm run prisma:seed
npm run dev
```

### 2. Frontend Setup
```bash
# From the root directory
flutter pub get
flutter run
```

## Deployment
This project is configured for one-click deployment on [Render](https://render.com) using the `render.yaml` blueprint. Connect your GitHub repository to Render and it will automatically deploy the API and database.
