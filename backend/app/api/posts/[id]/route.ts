import { NextResponse } from "next/server"
import db from "@/lib/db"
import { StatusKoas } from "@/config/types"
import { Prisma } from "@prisma/client"

export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  const { searchParams } = new URL(req.url)
  const postId = searchParams.get("id") || params.id

  try {
    const post = await db.posts.findUnique({
      where: {
        id: postId,
      },
      include: {
        users: true,
        koas: true,
        likes: true,
      },
    })

    if (!post) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 })
    }

    const likeCount = await db.likes.count({
      where: {
        postId,
      },
    })

    const postWithLikeCount = {
      ...post,
      likeCount,
    }

    return NextResponse.json(
      { message: "Get spesific post successfully", postWithLikeCount },
      { status: 200 }
    )
  } catch (error) {
    console.error(error)
    return NextResponse.json(
      { error: "An error occurred while fetching the post" },
      { status: 500 }
    )
  }
}

export async function POST(
  req: Request,
  { params }: { params: { id: string } }
) {
  const body = await req.json()
  const {
    userId,
    koasId,
    treatmentId,
    title,
    desc,
    patientRequirement,
    published,
    status,
  } = body

  try {
    if (!userId || !koasId || !treatmentId || !title || !desc) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      )
    }

    const koasProfile = await db.koasProfile.findUnique({
      where: { id: koasId },
      select: {
        status: true,
      },
    })

    if (!koasProfile) {
      return NextResponse.json(
        { error: "Koas Profile not found" },
        { status: 404 }
      )
    }

    if (koasProfile.status !== StatusKoas.Approved) {
      return NextResponse.json(
        { error: "Dont have an access to post before status approved" },
        { status: 400 }
      )
    }

    const post = await db.posts.create({
      data: {
        title,
        desc,
        patientRequirement,
        status,
        published,
        users: { connect: { id: String(userId) } },
        koas: { connect: { id: String(koasId) } },
        treatmentId: String(treatmentId), // Assuming this is a relation as well
      } as Prisma.PostsCreateInput,
    })

    return NextResponse.json(post, { status: 201 })
  } catch (error) {
    console.error(error)
    return NextResponse.json(
      { error: "An error occurred while creating the post" },
      { status: 500 }
    )
  }
}

export async function PATCH(
  req: Request,
  { params }: { params: { id: string } }
) {
  const { searchParams } = new URL(req.url)
  const postId = searchParams.get("id") || params.id

  const body = await req.json()
  const {
    userId,
    koasId,
    title,
    desc,
    patientRequirement,
    status,
    published,
    treatmentId,
  } = body

  try {
    const post = await db.posts.findUnique({
      where: { id: postId },
    })

    if (!post) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 })
    }

    const updatedPost = await db.posts.update({
      where: { id: postId },
      data: {
        title: title ?? post.title, // Jika title ada di body, ganti, jika tidak gunakan data lama
        desc: desc ?? post.desc,
        patientRequirement: patientRequirement ?? post.patientRequirement,
        status: status ?? post.status,
        published: published ?? post.published,
        treatmentId: treatmentId ?? post.treatmentId,
        users: userId ? { connect: { id: String(userId) } } : undefined,
        koas: koasId ? { connect: { id: String(koasId) } } : undefined,
      } as Prisma.PostsUpdateInput,
    })

    if (!title && !desc && !patientRequirement) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      )
    }

    return NextResponse.json(updatedPost, { status: 200 })
  } catch (error) {
    console.error(error)
    return NextResponse.json(
      { error: "An error occurred while updating the post" },
      { status: 500 }
    )
  }
}

export async function PUT(
  req: Request,
  { params }: { params: { id: string } }
) {
  const { searchParams } = new URL(req.url)
  const postId = searchParams.get("id") || params.id

  const body = await req.json()
  const {
    userId,
    koasId,
    title,
    desc,
    patientRequirement,
    status,
    published,
    treatmentId,
  } = body

  try {
    const post = await db.posts.findUnique({
      where: { id: postId },
    })

    if (!post) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 })
    }

    const updatedPost = await db.posts.update({
      where: { id: postId },
      data: {
        title,
        desc,
        patientRequirement,
        status,
        published,
        treatmentId: String(treatmentId),
        users: { connect: { id: String(userId) } },
        koas: { connect: { id: String(koasId) } },
      } as Prisma.PostsUpdateInput,
    })

    return NextResponse.json(updatedPost, { status: 200 })
  } catch (error) {
    console.error(error)
    return NextResponse.json(
      { error: "An error occurred while updating the post" },
      { status: 500 }
    )
  }
}

export async function DELETE(
  req: Request,
  { params }: { params: { id: string } }
) {
  const { searchParams } = new URL(req.url)
  const postId = searchParams.get("id") || params.id

  try {
    const post = await db.posts.findUnique({
      where: { id: postId },
    })

    if (!post) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 })
    }

    await db.posts.delete({
      where: { id: postId },
    })

    return NextResponse.json(
      { message: "Post deleted successfully" },
      { status: 200 }
    )
  } catch (error) {
    console.error(error)
    return NextResponse.json(
      { error: "An error occurred while deleting the post" },
      { status: 500 }
    )
  }
}
