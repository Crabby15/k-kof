# JasaDekat Web Deployment

This repository can be deployed as a static Flutter Web app behind Docker and Nginx. The provided setup serves it at `http://<server-ip>:8080/jasa-dekat/`. The same container works on x86_64 VPSs and ARM64 Raspberry Pi/Orange Pi systems because the Flutter build is static and Nginx provides the runtime.

## Build

On a machine with Flutter installed, run:

```powershell
./scripts/build_web.ps1
```

Or on Linux/macOS:

```sh
flutter pub get
flutter build web --release --base-href /jasa-dekat/
```

The output is `build/web/`. Build it on any supported development machine; the generated web files are architecture independent.

## Run on a VPS or ARM board

Copy/clone the project including `build/web/` to the server, install Docker Engine and the Docker Compose plugin, then run from the project directory:

```sh
docker compose up -d --build
```

Open `http://<server-ip>:8080/jasa-dekat/`. Allow inbound TCP port 8080 in the host/cloud firewall. To update, copy the new `build/web/` and run `docker compose up -d --build` again. To stop, run `docker compose down`.

## HTTPS and reviewer URL

The container serves HTTP and is intended to sit behind an HTTPS reverse proxy (for example, an existing Nginx/Caddy proxy) that forwards the `/jasa-dekat/` path to `127.0.0.1:8080`. Set the proxy's externally reachable URL to `https://<domain-or-ip>/jasa-dekat/`. A public HTTPS certificate must be available for that domain or IP. The current repository has no server address, domain, SSH credentials, DNS, or TLS certificate configured, so it cannot publish or verify a public URL by itself.

## Review evidence

- App screenshots already in the repository: `screenshots/01-login-mobile.png`, `screenshots/02-login-desktop.png`, `screenshots/03-register-mobile.png`, and `screenshots/04-home-mobile.png`.
- App tests: `flutter test`.
- Release build: `flutter build web --release --base-href /jasa-dekat/`.
- The app is a local-data prototype; bookings and preferences are stored in the browser for each origin and do not sync across devices.
