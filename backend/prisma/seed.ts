import { PrismaClient } from "@prisma/client"
import bcrypt from "bcryptjs"
import { users } from "@/data/users" // Ensure this contains an array of user objects
import { createSeedClient } from "@snaplet/seed"
import { Role } from "@/config/types"

const prisma = new PrismaClient()

async function main() {
  // Truncate all tables in the database
  const seed = await createSeedClient()
  await seed.$resetDatabase()

  for (const user of users) {
    const hash = await bcrypt.hash(user.password, 10)

    // Create user
    const createdUser = await prisma.users.create({
      data: {
        ...user,
        username: `${user.firstname}.${user.lastname}`,
        password: hash,
      },
    })

    if (user.role === Role.Koas) {
      // Create koas
      await prisma.koasProfile.create({
        data: {
          userId: createdUser.id,
        },
      })
    } else if (user.role === Role.Pasien) {
      // Create pasien
      await prisma.pasienProfile.create({
        data: {
          userId: createdUser.id,
        },
      })
    }
  }

  console.log("Data seed added:", users)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
