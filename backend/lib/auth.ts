import type { NextAuthOptions } from "next-auth"
import { compare } from "bcryptjs"
import Credentials from "next-auth/providers/credentials"
import db from "@/lib/db"

export const authOptions: NextAuthOptions = {
  session: {
    strategy: "jwt",
  },
  providers: [
    Credentials({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        const user = await db.users.findUnique({
          where: {
            email: credentials?.email,
          },
        })

        if (user && (await compare(credentials!.password, user.password))) {
          return { id: user.id, email: user.email, role: user.role }
        }

        return null
      },
    }),
  ],
}
