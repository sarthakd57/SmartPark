const mongoose = require("mongoose");

const slotSchema = new mongoose.Schema({
  lot_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "ParkingLot",
    required: true
  },
  slot_number: {
    type: String,
    required: true
  },
  is_available: {
    type: Boolean,
    default: true
  },
  current_booking: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Booking",
    default: null
  }
}, { timestamps: true });

module.exports = mongoose.model("Slot", slotSchema);