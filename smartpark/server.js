const express = require("express");
const http = require("http");
const dotenv = require("dotenv");
const cors = require("cors");
const { Server } = require("socket.io");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const parkingRoutes = require("./routes/parkingRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const { setIoInstance } = require("./controllers/paymentController");

dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

setIoInstance(io);

const availabilityNamespace = io.of("/availability");

availabilityNamespace.on("connection", (socket) => {
  socket.on("joinLot", (lotId) => {
    socket.join(`lot:${lotId}`);
  });

  socket.on("disconnect", () => {
    // no-op for now
  });
});

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Park Smart API Running");
});

app.use("/api/auth", authRoutes);
app.use("/api/parking", parkingRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/payment", paymentRoutes);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

