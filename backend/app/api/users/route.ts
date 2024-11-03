import db from "@/lib/db"
import { NextResponse } from "next/server"
import bcrypt from "bcryptjs"
import { userValidation, validateData } from "@/utils/validation"
import { Prisma } from "@prisma/client"

import { Role, UserQueryParams } from "@/config/types"
import { parseSearchParams } from "@/helper/user_helper"

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const query: UserQueryParams = parseSearchParams(searchParams)

  try {
    const users = await db.users.findMany({
      where: {
        ...query,
      } as Prisma.UsersWhereInput,
      orderBy: {
        username: "asc",
      },
      include: { koasProfile: true, pasienProfile: true },
    })

    const filteredUsers = users.map((user) => {
      if (user.role === Role.Koas) {
        return {
          ...user,
          pasienProfile: undefined, // sembunyikan pasien profile
        }
      } else if (user.role === Role.Pasien) {
        return {
          ...user,
          koasProfile: undefined, // sembunyikan koas profile
        }
      } else {
        return {
          ...user,
          koasProfile: undefined,
          pasienProfile: undefined,
        }
      }
      // return user
    })

    return NextResponse.json(filteredUsers, { status: 200 })
  } catch (error) {
    console.error("Error fetching users", error)
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    )
  }
}

export async function POST(req: Request) {
  const body = await req.json()
  const { firstname, lastname, email, password, phone, role, profile } = body

  const hash = await bcrypt.hash(password, 12)
  const resValidation = validateData(userValidation, body)

  if (!resValidation.success) {
    return NextResponse.json({ error: resValidation.errors }, { status: 400 })
  }

  const existingUser = await db.users.findUnique({
    where: { email },
  })

  if (existingUser) {
    return NextResponse.json(
      { error: "Email is already registered." },
      { status: 400 }
    )
  }

  try {
    const username = `${firstname.toLowerCase()}.${lastname.toLowerCase()}`

    const newUser = await db.users.create({
      data: {
        firstname,
        lastname,
        username,
        email,
        password: hash,
        phone,
        role,
      } as Prisma.UsersCreateInput,
    })

    if (newUser.role === Role.Koas) {
      await db.koasProfile.create({
        data: {
          ...profile,
          userId: newUser.id,
        },
      })
    } else if (newUser.role === Role.Pasien) {
      await db.pasienProfile.create({
        data: {
          ...profile,
          userId: newUser.id,
        },
      })
    }

    return NextResponse.json(newUser, { status: 201 })
  } catch (error) {
    console.error("Error creating user", error)
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    )
  }
}
