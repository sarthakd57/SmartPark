const mongoose = require("mongoose");
const Booking = require("../models/Booking");
const ParkingLot = require("../models/ParkingLot");
const { _allocateSlotForBooking } = require("./parkingController");

// POST /api/bookings
exports.createBooking = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const userId = req.user._id;
    const { lotId, durationHours } = req.body;

    if (!lotId || !durationHours) {
      await session.abortTransaction();
      session.endSession();
      return res.status(400).json({ message: "lotId and durationHours are required" });
    }

    const lot = await ParkingLot.findById(lotId).session(session);
    if (!lot || !lot.is_active) {
      await session.abortTransaction();
      session.endSession();
      return res.status(404).json({ message: "Parking lot not found" });
    }

    if (lot.available_slots <= 0) {
      await session.abortTransaction();
      session.endSession();
      return res.status(400).json({ message: "No available slots" });
    }

    const booking = await _allocateSlotForBooking(lotId, userId, session);

    if (!booking) {
      await session.abortTransaction();
      session.endSession();
      return res.status(400).json({ message: "No available slots" });
    }

    const startTime = new Date();
    const endTime = new Date(startTime.getTime() + durationHours * 60 * 60 * 1000);
    const totalPrice = durationHours * lot.price_per_hour;

    booking.start_time = startTime;
    booking.end_time = endTime;
    booking.total_price = totalPrice;

    await booking.save({ session });

    await session.commitTransaction();
    session.endSession();

    res.status(201).json(booking);
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    res.status(500).json({ error: error.message });
  }
};

// GET /api/bookings/me
exports.getMyBookings = async (req, res) => {
  try {
    const userId = req.user._id;

    const bookings = await Booking.find({ user_id: userId })
      .populate("lot_id")
      .populate("slot_id")
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// GET /api/admin/bookings?lotId=...
exports.getBookingsForLot = async (req, res) => {
  try {
    const { lotId } = req.query;

    const filter = {};
    if (lotId) {
      filter.lot_id = lotId;
    }

    const bookings = await Booking.find(filter)
      .populate("user_id")
      .populate("lot_id")
      .populate("slot_id")
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};



