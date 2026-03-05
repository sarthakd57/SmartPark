const express = require("express");
const router = express.Router();
const {
  createParkingLot,
  getLots,
  getLotById
} = require("../controllers/parkingController");
const { authenticate, authorizeAdmin } = require("../middleware/authMiddleware");

// Admin: create parking lots
router.post("/admin/lots", authenticate, authorizeAdmin, createParkingLot);

// Public/user: list and view lots
router.get("/lots", getLots);
router.get("/lots/:id", getLotById);

module.exports = router;
