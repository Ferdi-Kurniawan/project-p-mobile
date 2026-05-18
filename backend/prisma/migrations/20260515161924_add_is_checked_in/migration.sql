/*
  Warnings:

  - The values [CHECKED_IN] on the enum `Status` will be removed. If these variants are still used in the database, this will fail.
  - A unique constraint covering the columns `[ticket_code]` on the table `bookings` will be added. If there are existing duplicate values, this will fail.
  - The required column `ticket_code` was added to the `bookings` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.
  - Added the required column `updatedAt` to the `bookings` table without a default value. This is not possible if the table is not empty.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "Status_new" AS ENUM ('PENDING', 'PENDING_VERIFICATION', 'PAID', 'CANCELLED', 'EXPIRED');
ALTER TABLE "public"."bookings" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "bookings" ALTER COLUMN "status" TYPE "Status_new" USING ("status"::text::"Status_new");
ALTER TYPE "Status" RENAME TO "Status_old";
ALTER TYPE "Status_new" RENAME TO "Status";
DROP TYPE "public"."Status_old";
ALTER TABLE "bookings" ALTER COLUMN "status" SET DEFAULT 'PENDING';
COMMIT;

-- AlterTable
ALTER TABLE "bookings" ADD COLUMN     "checked_in_at" TIMESTAMP(3),
ADD COLUMN     "is_checked_in" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "paidAt" TIMESTAMP(3),
ADD COLUMN     "payment_method" TEXT,
ADD COLUMN     "payment_proof" TEXT,
ADD COLUMN     "ticket_code" TEXT NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "bookings_ticket_code_key" ON "bookings"("ticket_code");
