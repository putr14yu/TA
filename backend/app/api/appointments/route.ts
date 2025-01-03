import { NextResponse } from "next/server";
import db from "@/lib/db";

export async function GET(req: Request) {
  try {
    // Mengambil semua appointment dengan data terkait
    const appointments = await db.appointment.findMany({
      select: {
        id: true,
        pasienId: true,
        koasId: true,
        scheduleId: true,
        timeslotId: true,
        date: true,
        status: true, // Status digunakan untuk filter
        pasien: {
          select: {
            id: true,
            age: true,
            gender: true,
            user: {
              select: {
                id: true,
                name: true,
                phone: true,
              },
            },
          },
        },
        koas: {
          select: {
            id: true,
            koasNumber: true,
            user: {
              select: {
                id: true,
                name: true,
                phone: true,
              },
            },
          },
        },
        schedule: {
          select: {
            id: true,
            dateStart: true,
            dateEnd: true,
            post: {
              select: {
                id: true,
                title: true,
                requiredParticipant: true,
              },
            },
            timeslot: {
              select: {
                id: true,
                startTime: true,
                endTime: true,
                maxParticipants: true,
                currentParticipants: true, // Akan diperbarui
                isAvailable: true,
              },
            },
          },
        },
      },
    });

    // Mengolah data untuk memperbarui currentParticipants berdasarkan status dan timeslot
    const updatedAppointments = appointments.map((appointment) => {
      const { schedule, timeslotId, date, status } = appointment;

      // Hitung jumlah peserta "Confirmed" untuk timeslot tertentu
      const currentParticipants = appointments.filter(
        (a) =>
          a.schedule?.id === schedule?.id &&
          a.timeslotId === timeslotId &&
          a.date === date &&
          a.status === "Confirmed"
      ).length;

      const relatedTimeslot = schedule.timeslot.find(
        (slot) => slot.id === timeslotId
      );

      // Perbarui timeslot terkait
      // const updatedTimeslots = schedule.timeslot.map((timeslot) => ({
      //   ...timeslot,
      //   currentParticipants:
      //     timeslot.id === timeslotId
      //       ? currentParticipants // Update currentParticipants untuk timeslot tertentu
      //       : timeslot.currentParticipants,
      // }));

      return {
        ...appointment,
        schedule: {
          ...schedule,
          timeslot: relatedTimeslot,
        },
      };
    });

    // Mengembalikan data ke klien
    return NextResponse.json(
      {
        status: "Success",
        message: "Get all appointments successfully",
        data: { appointments: updatedAppointments }, // Return updated appointments
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error getting appointments:", error);

    // Mengembalikan respons error ke klien
    return NextResponse.json(
      { status: "Error", message: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  const body = await req.json();
  const { scheduleId, pasienId, koasId, timeslotId, date } = body;

  if (!scheduleId || !pasienId || !koasId || !timeslotId || !date) {
    return NextResponse.json(
      { error: "Missing required fields" },
      { status: 400 }
    );
  }

  try {
    // Cek apakah schedule, pasien, dan koas valid
    const schedule = await db.schedule.findUnique({
      where: { id: scheduleId },
      include: {
        post: true, // Mengambil data post terkait untuk validasi requiredParticipant
        timeslot: true, // Mengambil semua timeslot terkait schedule
      },
    });
    const pasien = await db.pasienProfile.findUnique({
      where: { id: pasienId },
    });
    const koas = await db.koasProfile.findUnique({
      where: { id: koasId },
    });

    if (!schedule || !pasien || !koas) {
      return NextResponse.json(
        { error: "Invalid schedule, pasien or koas" },
        { status: 404 }
      );
    }

    if (
      new Date(date) < new Date(schedule.dateStart) ||
      new Date(date) > new Date(schedule.dateEnd)
    ) {
      return NextResponse.json(
        { error: "Date is not within the schedule range" },
        { status: 400 }
      );
    }

    // Cek apakah timeslotId yang dipilih ada dalam schedule
    const selectedTimeslot = schedule.timeslot.find(
      (slot) => slot.id === timeslotId
    );

    if (!selectedTimeslot) {
      return NextResponse.json(
        { error: "Timeslot not found for the given schedule" },
        { status: 404 }
      );
    }

    if (!selectedTimeslot.isAvailable) {
      return NextResponse.json(
        { error: "Timeslot is fully booked or unavailable." },
        { status: 400 }
      );
    }

    // Membuat appointment baru
    const appointment = await db.appointment.create({
      data: {
        pasien: {
          connect: { id: pasienId },
        },
        koas: {
          connect: { id: koasId },
        },
        schedule: {
          connect: { id: scheduleId },
        },
        timeslot: {
          connect: { id: timeslotId },
        },
        date: new Date(date), // Pastikan untuk mengonversi date ke format Date
        status: "Pending", // Status awal adalah pending
      },
    });

    return NextResponse.json(
      {
        status: "Success",
        message: "Appointment created successfully.",
        data: { appointment },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Error creating appointment:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
