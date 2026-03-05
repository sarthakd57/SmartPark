const express = require("express");
const router = express.Router();
const {
  createBooking,
  getMyBookings,
  getBookingsForLot
} = require("../controllers/bookingController");
const { authenticate, authorizeAdmin } = require("../middleware/authMiddleware");

// User bookings
router.post("/", authenticate, createBooking);
router.get("/me", authenticate, getMyBookings);

// Admin bookings for a lot
router.get("/admin", authenticate, authorizeAdmin, getBookingsForLot);

module.exports = router;

