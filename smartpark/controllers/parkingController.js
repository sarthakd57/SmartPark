const ParkingLot = require("../models/ParkingLot");
const Slot = require("../models/Slot");
const Booking = require("../models/Booking");
const mongoose = require("mongoose");

exports.createParkingLot = async (req, res) => {
  try {
    const { name, address, latitude, longitude, total_slots, price_per_hour } = req.body;

    if (!name || latitude == null || longitude == null || !total_slots || !price_per_hour) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const parkingLot = await ParkingLot.create({
      name,
      address,
      location: {
        type: "Point",
        coordinates: [longitude, latitude]
      },
      total_slots,
      available_slots: total_slots,
      price_per_hour,
      created_by: req.user ? req.user._id : undefined
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

// GET /api/parking/lots?lat=&lng=&radius=
exports.getLots = async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;

    let query = { is_active: true };

    if (lat && lng) {
      const maxDistance = parseInt(radius || "5000", 10);
      query = {
        ...query,
        location: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [parseFloat(lng), parseFloat(lat)]
            },
            $maxDistance: maxDistance
          }
        }
      };
    }

    const parkingLots = await ParkingLot.find(query);
    res.json(parkingLots);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// GET /api/parking/lots/:id
exports.getLotById = async (req, res) => {
  try {
    const { id } = req.params;

    const lot = await ParkingLot.findById(id);
    if (!lot) {
      return res.status(404).json({ message: "Parking lot not found" });
    }

    const slots = await Slot.find({ lot_id: id });

    res.json({
      lot,
      slots
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Utility used by booking controller to allocate a slot atomically
exports._allocateSlotForBooking = async (lotId, userId, session) => {
  const slot = await Slot.findOneAndUpdate(
    { lot_id: lotId, is_available: true },
    { $set: { is_available: false } },
    { new: true, session }
  );

  if (!slot) {
    return null;
  }

  await ParkingLot.findByIdAndUpdate(
    lotId,
    { $inc: { available_slots: -1 } },
    { session }
  );

  const [booking] = await Booking.create(
    [
      {
        user_id: userId,
        lot_id: lotId,
        slot_id: slot._id
      }
    ],
    { session }
  );

  return booking;
};