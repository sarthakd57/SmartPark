const ParkingLot = require("../models/ParkingLot");
const Slot = require("../models/Slot");
const Booking = require("../models/Booking");
const mongoose = require("mongoose");



exports.createParkingLot = async (req, res) => {
  try {
    const { name, latitude, longitude, total_slots, price_per_hour } = req.body;

    const parkingLot = await ParkingLot.create({
      name,
      location: {
        type: "Point",
        coordinates: [longitude, latitude]
      },
      total_slots,
      available_slots: total_slots,
      price_per_hour
    });

    const slots = [];

    for (let i = 1; i <= total_slots; i++) {
      slots.push({
        lot_id: parkingLot._id,
        slot_number: `S${i}`
      });
    }

    await Slot.insertMany(slots);

    res.status(201).json(parkingLot);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getNearbyParking = async (req, res) => {
  try {
    const { lat, lng, radius = 5000 } = req.query;

    const parkingLots = await ParkingLot.find({
      location: {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [parseFloat(lng), parseFloat(lat)]
          },
          $maxDistance: parseInt(radius)
        }
      }
    });

    res.json(parkingLots);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getSlotsByLot = async (req, res) => {
  try {
    const { lotId } = req.params;

    const slots = await Slot.find({ lot_id: lotId });

    res.json(slots);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.completeBooking = async (req, res) => {
  try {
    const { bookingId } = req.params;

    const booking = await Booking.findById(bookingId)
      .populate("lot_id")
      .populate("slot_id");

    if (!booking || booking.status !== "active") {
      return res.status(400).json({ error: "Invalid booking" });
    }

    booking.end_time = new Date();

    const hours = Math.ceil(
      (booking.end_time - booking.start_time) / (1000 * 60 * 60)
    );

    booking.total_price = hours * booking.lot_id.price_per_hour;
    booking.status = "completed";

    await booking.save();

    booking.slot_id.is_available = true;
    await booking.slot_id.save();

    await ParkingLot.findByIdAndUpdate(booking.lot_id._id, {
      $inc: { available_slots: 1 }
    });

    res.json(booking);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
exports.bookSlot = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { lotId } = req.params;
    const { user_id } = req.body;

    // Atomically find and update slot
    const slot = await Slot.findOneAndUpdate(
      { lot_id: lotId, is_available: true },
      { $set: { is_available: false } },
      { new: true, session }
    );

    if (!slot) {
      await session.abortTransaction();
      session.endSession();
      return res.status(400).json({ error: "No available slots" });
    }

    await ParkingLot.findByIdAndUpdate(
      lotId,
      { $inc: { available_slots: -1 } },
      { session }
    );

    const booking = await Booking.create(
      [{
        user_id,
        lot_id: lotId,
        slot_id: slot._id
      }],
      { session }
    );

    await session.commitTransaction();
    session.endSession();

    res.status(201).json(booking[0]);

  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    res.status(500).json({ error: error.message });
  }
};