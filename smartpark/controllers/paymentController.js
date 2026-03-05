const crypto = require("crypto");
const Razorpay = require("razorpay");
const Booking = require("../models/Booking");
const ParkingLot = require("../models/ParkingLot");

const getRazorpayInstance = () => {
  const { RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET } = process.env;

  if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
    throw new Error("Razorpay keys are not configured. Please set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in your environment.");
  }

  return new Razorpay({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_KEY_SECRET
  });
};

let ioInstance;

const setIoInstance = (io) => {
  ioInstance = io;
};

exports.setIoInstance = setIoInstance;

exports.createOrder = async (req, res) => {
  try {
    const { bookingId } = req.body;

    const booking = await Booking.findById(bookingId).populate("lot_id");
    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    const amountInPaise = Math.round((booking.total_price || 0) * 100);

    const options = {
      amount: amountInPaise,
      currency: "INR",
      receipt: bookingId.toString()
    };

    const razorpay = getRazorpayInstance();
    const order = await razorpay.orders.create(options);

    booking.order_id = order.id;
    await booking.save();

    res.json({
      id: order.id,
      amount: order.amount,
      currency: order.currency,
      bookingId: booking._id
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.verifyPayment = async (req, res) => {
  try {
    const { bookingId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    const body = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expectedSignature = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest("hex");

    if (expectedSignature !== razorpay_signature) {
      booking.payment_status = "failed";
      await booking.save();
      return res.status(400).json({ message: "Invalid payment signature" });
    }

    booking.payment_id = razorpay_payment_id;
    booking.payment_status = "paid";
    await booking.save();

    // Emit availability update for the lot
    if (ioInstance && booking.lot_id) {
      const lot = await ParkingLot.findById(booking.lot_id);
      if (lot) {
        ioInstance
          .of("/availability")
          .to(`lot:${lot._id.toString()}`)
          .emit("availabilityUpdated", {
            lotId: lot._id,
            availableSlots: lot.available_slots
          });
      }
    }

    res.json({ message: "Payment successful" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};