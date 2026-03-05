# Park Smart – Demo Guide

## Prerequisites

- MongoDB running locally (default port).
- Node dependencies installed in `smartpark`:
  - `npm install`
- Flutter dependencies installed in `smartparkapp`:
  - `flutter pub get`
- Razorpay test keys configured in `.env` (copy from `.env.example`).

## Run backend

```bash
cd smartpark
npm run dev
```

Backend will start on `http://localhost:5000`.

## Run Flutter app (Android)

```bash
cd smartparkapp
flutter run
```

Make sure the device/emulator can reach `http://localhost:5000`. If not, change `baseUrl` in `lib/main.dart`.

## Demo flow

1. **Register admin (once)**  
   - In `.env`, set `ADMIN_EMAIL=admin@example.com`.  
   - In the app, register with `admin@example.com` to get an admin account automatically.

2. **Admin: create parking lot**
   - Log in as admin.
   - Tap `Admin` in the app bar → `Admin Lots`.
   - Tap `+` and fill name, address, coordinates, total slots, and price/hour.

3. **User: book a slot and pay**
   - Log out and register/login as a normal user (any other email).
   - On home screen, pull to refresh to see the new lot.
   - Tap the lot → choose duration → `Book & Pay`.
   - Razorpay test checkout opens; use test card/UPI from Razorpay docs.
   - On success, backend verifies payment and marks booking as paid.

4. **See bookings**
   - Tap calendar icon in the app bar to open **My Bookings**.
   - Verify booking status and amount.

5. **Map and realtime**
   - From Home, tap `Map` to open Google Map with parking markers.
   - When new bookings are paid, availability is pushed via Socket.io
     to any clients connected to `/availability`, and the list/map
     updates accordingly.

