# Trazzo – Setup & Run Guide

## Prerequisites

- **Docker Desktop** – running
- **Java 17+**
- **Flutter 3.x**
- **Maven** (or use `./mvnw` in backend)

---

## 1. Start Database (PostgreSQL + Redis)

```bash
./docker-up.sh
```

Wait until you see: **Docker services started successfully**

- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

**Stop:**
```bash
./docker-down.sh
```

---

## 2. Run Backend

```bash
./run-backend.sh
```

Wait until you see: **Started TrazzoApplication**

Backend: `http://localhost:8080`

Press `Ctrl+C` to stop.

---

## 3. Run Flutter App

In a **separate terminal**:

```bash
./run-mobile.sh
```

Or manually:
```bash
cd mobile/trazzo_app
flutter pub get
flutter run
```

To run on a specific device (e.g. iPhone):
```bash
flutter devices                    # list devices
flutter run -d <device-id>         # run on device
```

---

## PGAdmin – Database Configuration

### Connection details

| Field   | Value        |
|--------|---------------|
| Host   | `localhost`   |
| Port   | `5432`        |
| Database | `trazzo`   |
| Username | `trazzo_user` |
| Password | `trazzo_pass` |

### Steps in pgAdmin

1. Open **pgAdmin**
2. Right‑click **Servers** → **Register** → **Server**
3. **General** tab:
   - **Name:** `Trazzo Local`
4. **Connection** tab:
   - **Host:** `localhost`
   - **Port:** `5432`
   - **Maintenance database:** `trazzo`
   - **Username:** `trazzo_user`
   - **Password:** `trazzo_pass`
   - Check **Save password** (optional)
5. Click **Save**

To query: right‑click `trazzo` → **Query Tool** → run SQL.

---

## Quick Reference

| Step   | Command          |
|--------|------------------|
| Database | `./docker-up.sh` |
| Backend  | `./run-backend.sh` |
| Flutter  | `./run-mobile.sh` |
| Stop DB | `./docker-down.sh` |

---

## Mobile app config (physical device)

In `mobile/trazzo_app/lib/core/config/app_config.dart`:

- Set `devApiBaseUrl` to your **Mac’s IP** (e.g. `http://192.168.1.6:8080`), not `localhost`
- iPhone and Mac must be on the same Wi‑Fi

---

## UPI config (pay on delivery)

In `mobile/trazzo_app/lib/core/config/app_config.dart`:

- `upiVpa`: your UPI ID (e.g. `you@paytm`)
- `upiPayeeName`: name shown in the UPI app
