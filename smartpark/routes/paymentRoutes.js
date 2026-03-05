const express = require("express");
const router = express.Router();
const {
  createOrder,
  verifyPayment
} = require("../controllers/paymentController");
const { authenticate } = require("../middleware/authMiddleware");

router.post("/create-order", authenticate, createOrder);
router.post("/verify", authenticate, verifyPayment);

module.exports = router;