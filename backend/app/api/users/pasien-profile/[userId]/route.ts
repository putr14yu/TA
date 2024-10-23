import { NextResponse } from "next/server"
import db from "@/lib/db"
import { Gender, Prisma } from "@prisma/client"

export async function GET(
  req: Request,
  { params }: { params: { userId: string } }
) {
  const { searchParams } = new URL(req.url)
  const userId = searchParams.get("userId") || params.userId

  if (!userId) {
    return NextResponse.json({ error: "User ID is required" }, { status: 400 })
  }

  try {
    const user = await db.users.findUnique({
      where: {
        id: userId,
      },
      include: {
        pasienProfile: true,
      },
    })

    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 })
    }

    return NextResponse.json(user, { status: 200 })
  } catch (error) {
    console.error("Error fetching user profile:", error) // Log error
    return NextResponse.json(
      { error: "Error fetching user profile" },
      { status: 500 }
    )
  }
}

export async function PATCH(
  req: Request,
  { params }: { params: { userId: string } }
) {
  const { searchParams } = new URL(req.url)
  const userId = searchParams.get("userId") || params.userId

  const body = await req.json()

  try {
    if (!userId) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400 }
      )
    }

    const user = await db.users.findUnique({
      where: {
        id: userId,
      },
      include: {
        pasienProfile: true,
      },
    })

    if (!user || !user.pasienProfile) {
      return NextResponse.json(
        { error: "Pasien profile not found" },
        { status: 404 }
      )
    }

    const updateProfile = await db.pasienProfile.update({
      where: { userId: String(userId) },
      data: {
        age: body.age || user.pasienProfile.age,
        gender: body.gender || user.pasienProfile.gender,
        bio: body.bio || user.pasienProfile.bio,
      } as Prisma.PasienProfileUpdateInput,
    })

    return NextResponse.json(
      { data: updateProfile, message: "Profile updated successfully" },
      { status: 200 }
    )
  } catch (error) {
    console.error("Error update pasien profile:", error) // Log error
    return NextResponse.json(
      { error: "Error fetching user profile" },
      { status: 500 }
    )
  }
}

export async function PUT(
  req: Request,
  { params }: { params: { userId: string } }
) {
  const { searchParams } = new URL(req.url)
  const userId = searchParams.get("userId") || params.userId

  const body = await req.json()

  try {
    if (!userId) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400 }
      )
    }

    const user = await db.users.findUnique({
      where: {
        id: userId,
      },
      include: {
        pasienProfile: true,
      },
    })

    if (!user || !user.pasienProfile) {
      return NextResponse.json(
        { error: "Pasien profile not found" },
        { status: 404 }
      )
    }

    const updateProfile = await db.pasienProfile.update({
      where: { userId: String(userId) },
      data: {
        age: body.age || user.pasienProfile.age,
        gender: body.gender || user.pasienProfile.gender,
        bio: body.bio || user.pasienProfile.bio,
      } as Prisma.PasienProfileUpdateInput,
    })

    return NextResponse.json(
      { data: updateProfile, message: "Profile updated successfully" },
      { status: 200 }
    )
  } catch (error) {
    console.error("Error update pasien profile:", error) // Log error
    return NextResponse.json(
      { error: "Error fetching user profile" },
      { status: 500 }
    )
  }
}

export async function DELETE(
  req: Request,
  { params }: { params: { userId: string } }
) {
  const { searchParams } = new URL(req.url)
  const userId = searchParams.get("userId") || params.userId
  const reset = searchParams.get("reset") === "true" // Ambil opsi reset dari query

  try {
    if (!userId) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400 }
      )
    }

    const user = await db.users.findUnique({
      where: {
        id: userId,
      },
      include: {
        pasienProfile: true,
      },
    })

    if (!user || !user.pasienProfile) {
      return NextResponse.json(
        { error: "Pasien profile not found" },
        { status: 404 }
      )
    }

    if (reset) {
      //   Jika reset = true, reset pasienProfile menjadi null
      const deletedProfile = await db.pasienProfile.update({
        where: {
          userId: userId,
        },
        data: {
          age: null,
          gender: null,
          bio: null,
        } as Prisma.PasienProfileUpdateInput,
      })

      return NextResponse.json(
        {
          data: deletedProfile,
          message: "Pasien profile partially cleared successfully",
        },
        { status: 200 }
      )
    } else {
      // Jika reset = false, hapus seluruh record pasienProfile
      const deletedProfile = await db.pasienProfile.delete({
        where: {
          userId: userId,
        },
      })

      return NextResponse.json(
        {
          data: deletedProfile,
          message: "Pasien profile completely deleted successfully",
        },
        { status: 200 }
      )
    }
  } catch (error) {
    console.error("Error deleting pasien profile:", error) // Log error
    return NextResponse.json(
      { error: "Error deleting pasien profile" },
      { status: 500 }
    )
  }
}
