import { Prisma } from "@prisma/client";
import { NextResponse } from "next/server";
import db from "@/lib/db";
import bcrypt from "bcryptjs";

import { Role } from "@/config/enum";
import { SignUpSchema } from "@/lib/schemas";
import { UserQueryString } from "@/config/types";
import { getUserByEmail, parseSearchParams, genUsername } from "@/helpers/user";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const query: UserQueryString = parseSearchParams(searchParams);

  try {
    const user = await db.user.findMany({
      where: {
        ...query,
      } as Prisma.UserWhereInput,
      orderBy: {
        name: "asc",
      },
      include: { KoasProfile: true, PasienProfile: true },
    });

    const filtereduser = user.map((user) => {
      if (user.role === Role.Koas) {
        return {
          ...user,
          PasienProfile: undefined, // sembunyikan pasien profile
        };
      } else if (user.role === Role.Pasien) {
        return {
          ...user,
          koasProfile: undefined, // sembunyikan koas profile
        };
      } else {
        return {
          ...user,
          koasProfile: undefined,
          PasienProfile: undefined,
        };
      }
      // return user
    });

    return NextResponse.json(
      {
        status: "Success",
        message: "User retrived successfully",
        data: { user: filtereduser },
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching user", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  const body = await req.json();
  const { givenName, familyName, email, password, phone, role, profile } = body;

  const validateFields = SignUpSchema.safeParse(body);

  if (!validateFields.success) {
    return NextResponse.json({ error: validateFields.error }, { status: 400 });
  }

  const existingUser = await getUserByEmail(email);

  if (existingUser) {
    return NextResponse.json(
      { error: "Email already in use." },
      { status: 400 }
    );
  }

  try {
    const name = await genUsername(givenName, familyName);
    const hash = await bcrypt.hash(password, 10);

    const newUser = await db.user.create({
      data: {
        givenName,
        familyName,
        name,
        email,
        password: hash,
        phone,
        role,
      } as Prisma.UserCreateInput,
    });

    if (newUser.role === Role.Koas) {
      await db.koasProfile.create({
        data: {
          ...profile,
          userId: newUser.id,
        },
      });
    } else if (newUser.role === Role.Pasien) {
      await db.pasienProfile.create({
        data: {
          ...profile,
          userId: newUser.id,
        },
      });
    }

    return NextResponse.json(
      {
        status: "Success",
        message: "User created successfully",
        data: { user: newUser },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Error creating user", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
