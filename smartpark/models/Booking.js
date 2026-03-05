const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  lot_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "ParkingLot",
    required: true
  },
  payment_id: String,
  order_id: String,
  payment_status: {
    type: String,
    enum: ["pending", "paid", "failed"],
    default: "pending"
},
  slot_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Slot",
    required: true
  },
  start_time: {
    type: Date,
    default: Date.now
  },
  end_time: Date,
  total_price: Number,
  status: {
    type: String,
    enum: ["active", "completed", "cancelled"],
    default: "active"
  }
}, { timestamps: true });

module.exports = mongoose.model("Booking", bookingSchema);