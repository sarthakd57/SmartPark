const mongoose = require("mongoose");

const parkingLotSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true
    },
    address: {
      type: String
    },
    location: {
      type: {
        type: String,
        enum: ["Point"],
        required: true
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true
      }
    },
    total_slots: {
      type: Number,
      required: true
    },
    available_slots: {
      type: Number,
      required: true
    },
    price_per_hour: {
      type: Number,
      required: true
    },
    is_active: {
      type: Boolean,
      default: true
    },
    created_by: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    }
  },
  { timestamps: true }
);

// Important for geo queries
parkingLotSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("ParkingLot", parkingLotSchema);