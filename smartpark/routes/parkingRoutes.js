const express = require("express");
const router = express.Router();

const {
  createParkingLot,
  getNearbyParking,
  getSlotsByLot,
  bookSlot,
  completeBooking
} = require("../controllers/parkingController");

router.post("/create", createParkingLot);
router.get("/nearby", getNearbyParking);
router.get("/:lotId/slots", getSlotsByLot);
router.post("/:lotId/book", bookSlot);
router.put("/booking/:bookingId/complete", completeBooking);

module.exports = router;