import { NextResponse } from "next/server"
import db from "@/lib/db"
import { StatusKoas } from "@/config/types"
import { Prisma } from "@prisma/client"

export async function GET(req: Request) {
  try {
    const posts = await db.posts.findMany()

    if (!posts) {
      return NextResponse.json({ error: "Posts not found" }, { status: 404 })
    }

    const likeCount = await db.likes.count()

    const postsWithLikeCount = posts.map((post) => {
      return {
        ...post,
        likeCount,
      }
    })

    return NextResponse.json(postsWithLikeCount, { status: 200 })
  } catch (error) {
    console.error("Error fetching posts", error)
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    )
  }
}
