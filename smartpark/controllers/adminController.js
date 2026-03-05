exports.getDashboardStats = async (req, res) => {
  const totalLots = await ParkingLot.countDocuments();
  const totalBookings = await Booking.countDocuments();
  const activeBookings = await Booking.countDocuments({ status: "active" });

  res.json({
    totalLots,
    totalBookings,
    activeBookings
  });
};