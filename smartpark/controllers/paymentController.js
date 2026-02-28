const Razorpay = require("razorpay");
const Booking = require("../models/Booking");
require('dotenv').config();

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

exports.createOrder = async (req, res) => {
  try {
    const { bookingId, amount } = req.body;

    const options = {
      amount: amount * 100, // in paise
      currency: "INR",
      receipt: bookingId
    };

    const order = await razorpay.orders.create(options);

    await Booking.findByIdAndUpdate(bookingId, {
      order_id: order.id
    });

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.verifyPayment = async (req, res) => {
  try {
    const { bookingId, paymentId } = req.body;

    await Booking.findByIdAndUpdate(bookingId, {
      payment_id: paymentId,
      payment_status: "paid"
    });

    res.json({ message: "Payment successful" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};