JasaDekat

## Local Data & Persistence (demo reviewer)

Alur vertikal yang memakai penyimpanan lokal adalah **Booking/Pesanan** (Flutter `shared_preferences`, key `jasa_dekat.bookings.v1`, JSON versioned). Data tersimpan di device, terpisah dari session login demo.

Posisi implementasi:

- Model/entity dan JSON serialization: `lib/features/booking/domain/booking_request.dart`
- Repository local storage dan operasi CRUD: `lib/features/services/data/service_repository.dart` (`fetchBookings`, `createBooking`, `updateBooking`, `deleteBooking`)
- Submit/create dari form: `lib/features/booking/presentation/booking_page.dart`
- Read setelah buka/refresh, update status, delete: `lib/features/booking/presentation/booking_list_page.dart`
- Pintu masuk daftar: navigasi **Pesanan** pada `lib/app.dart`

Demo persistence: jalankan `flutter run`, buat booking melalui **Buat pesanan jasa**, buka tab **Pesanan**, ubah status lewat menu titik tiga dan coba hapus salah satu item. Tutup aplikasi lalu jalankan lagi pada device yang sama; karena akun demo hanya tersimpan di memori, daftar/masuk demo kembali bila diminta, lalu buka **Pesanan**. Booking yang belum dihapus muncul kembali. Tombol refresh di halaman Pesanan membaca ulang JSON dari storage lokal. Pada Flutter Web, storage mengikuti origin browser.

Model booking menyimpan `id`, `serviceId`, `customerName`, `scheduledAt`, `note`, `status`, dan `createdAt`. `pending` dapat diubah menjadi `confirmed` dan sebaliknya. Ini demo lokal; data tidak disinkronkan antar-device dan tidak menggantikan backend produksi.

## Prototype aplikasi

Prototype Flutter saat ini mencakup layar masuk/daftar dan beranda marketplace
dengan kategori serta contoh layanan. Implementasi ada di `lib/main.dart` dan
`lib/app.dart`. Akun yang dibuat tersimpan sementara di memori aplikasi untuk
demonstrasi alur; autentikasi Supabase dan penyimpanan permanen belum terhubung.

State management untuk pencarian jasa dan proses booking menggunakan Riverpod.
Lokasi kode, aliran data, daftar state, perintah test, dan prompt AI tercatat di
[`docs/state_management.md`](docs/state_management.md).

Scaffolding Android dan Web sudah tersedia. Pastikan Flutter SDK sudah masuk
PATH, buka terminal baru dari direktori proyek, lalu jalankan:

```sh
flutter pub get
flutter run -d chrome
```

Untuk menjalankan di emulator Android yang aktif, gunakan `flutter run`.

Untuk menguji alur demo, pilih **Daftar**, buat akun dengan email valid dan
kata sandi minimal 6 karakter, lalu keluar melalui menu avatar. Masuk kembali
menggunakan akun yang sama. Data akun hilang ketika aplikasi dimulai ulang.

Platform mobile untuk mempertemukan masyarakat yang membutuhkan bantuan/jasa dengan penyedia jasa di sekitar mereka.






Daftar Isi

Tentang Project

Masalah yang Diselesaikan

Solusi

Target Pengguna

Fitur Utama

User Flow

Teknologi

Arsitektur

Struktur Folder

Database

Persiapan Development

Instalasi

Environment Variables

Menjalankan Project

Build Release

Konvensi Commit

Roadmap

Keamanan dan Privasi

Kontribusi

License

Kontak

Tentang Project

JasaDekat adalah aplikasi mobile marketplace jasa lokal yang membantu pengguna menemukan orang yang memiliki kemampuan tertentu di sekitar mereka.

Contoh kebutuhan:

Mencari guru les.

Mencari teknisi komputer.

Mencari jasa desain.

Mencari editor video.

Mencari fotografer.

Mencari jasa perbaikan perangkat.

Mencari bantuan pekerjaan kecil di lingkungan sekitar.

Di sisi lain, orang yang memiliki skill dapat membuat profil, memasang layanan, menentukan harga, menerima permintaan, dan membangun reputasi melalui rating.

Value Proposition

Untuk pencari jasa:

Temukan orang yang bisa membantu, dekat dari lokasi kamu, dengan informasi harga, rating, dan layanan yang lebih jelas.

Untuk penyedia jasa:

Ubah kemampuan yang kamu punya menjadi peluang mendapatkan pelanggan di sekitar kamu.

Masalah yang Diselesaikan

Banyak kebutuhan jasa lokal masih ditemukan melalui:

rekomendasi teman;

grup chat;

media sosial;

posting komunitas;

pencarian yang tidak memiliki filter lokasi;

komunikasi dan harga yang tidak terstruktur.

Hal tersebut membuat pengguna kesulitan menjawab beberapa pertanyaan sederhana:

Siapa yang bisa mengerjakan?

Apakah lokasinya dekat?

Berapa kisaran harganya?

Apakah orang tersebut terpercaya?

Bagaimana cara menghubunginya?

Apa yang terjadi setelah saya memesan?

JasaDekat mencoba mengubah proses tersebut menjadi satu alur digital yang lebih terstruktur.

Solusi

JasaDekat menyediakan marketplace jasa berbasis lokasi dengan tiga elemen utama:

1. Discovery

Pengguna dapat mencari layanan berdasarkan kategori, kata kunci, lokasi, harga, dan rating.

2. Trust

Pengguna dapat melihat profil penyedia jasa, portofolio, rating, ulasan, dan informasi layanan sebelum menghubungi mereka.

3. Transaction Flow

Permintaan jasa dapat dibuat dan dipantau melalui status:

Menunggu → Diterima → Berlangsung → Selesai

Setelah pesanan selesai, pengguna dapat memberikan rating dan ulasan.

Target Pengguna

Customer

Orang yang membutuhkan jasa tertentu dengan cepat dan ingin menemukan penyedia jasa di sekitar mereka.

Service Provider

Pelajar, mahasiswa, freelancer, teknisi, pekerja lepas, UMKM, dan masyarakat umum yang memiliki skill dan ingin mendapatkan pelanggan.

Admin

Pihak yang mengelola kategori, moderasi konten, laporan pengguna, dan aktivitas platform.

Fitur Utama

Authentication

Register.

Login.

Logout.

Reset password.

Pengaturan profil.

Role pengguna:

customer

provider

admin

Pencarian Jasa

Search berdasarkan keyword.

Filter kategori.

Filter lokasi.

Filter harga.

Filter rating.

Sorting berdasarkan jarak, rating, atau harga.

Lokasi

Menampilkan lokasi pengguna.

Menentukan area layanan provider.

Menghitung perkiraan jarak.

Menemukan provider terdekat.

Untuk keamanan, aplikasi tidak perlu menampilkan alamat rumah lengkap pengguna.

Profil Provider

Profil provider berisi:

Nama.

Foto profil.

Deskripsi.

Skill.

Area layanan.

Harga mulai.

Rating.

Jumlah pesanan selesai.

Portofolio.

Daftar layanan.

Layanan

Provider dapat:

Membuat layanan.

Mengubah layanan.

Menghapus layanan.

Menentukan harga.

Menentukan estimasi waktu pengerjaan.

Menentukan area layanan.

Pemesanan

Customer dapat:

Memilih layanan.

Mengirim detail kebutuhan.

Menentukan jadwal.

Mengirim catatan tambahan.

Membuat permintaan jasa.

Melihat status pesanan.

Chat

Customer dan provider dapat berkomunikasi sebelum atau setelah pesanan dibuat.

Rating dan Review

Setelah pesanan selesai:

Customer memberikan rating.

Customer dapat menulis ulasan.

Rating masuk ke reputasi provider.

Report

Pengguna dapat melaporkan:

Penipuan.

Konten tidak pantas.

Profil palsu.

Spam.

Perilaku tidak sesuai.

Admin

Admin dapat:

Melihat pengguna.

Melihat layanan.

Memoderasi konten.

Memproses laporan.

Menonaktifkan akun bermasalah.

Melihat statistik dasar aplikasi.

User Flow

Customer

Buka aplikasi
    ↓
Login / Register
    ↓
Isi lokasi
    ↓
Homepage
    ↓
Cari jasa
    ↓
Filter / Sort
    ↓
Pilih provider
    ↓
Lihat profil & layanan
    ↓
Pilih layanan
    ↓
Kirim permintaan
    ↓
Provider menerima
    ↓
Chat / koordinasi
    ↓
Pesanan berlangsung
    ↓
Pesanan selesai
    ↓
Rating & Review

Provider

Register
    ↓
Pilih role Provider
    ↓
Lengkapi profil
    ↓
Tambahkan skill
    ↓
Tambahkan layanan
    ↓
Menunggu permintaan
    ↓
Terima / tolak pesanan
    ↓
Chat dengan customer
    ↓
Kerjakan pesanan
    ↓
Tandai selesai
    ↓
Menerima rating & review

Teknologi

Mobile

Flutter

Dart

Material 3

GoRouter

Riverpod

Backend

Supabase

PostgreSQL

Supabase Auth

Supabase Storage

Row Level Security (RLS)

Supabase Realtime

Integrasi yang Direncanakan

Geolocation

Maps

Push Notification

Image upload

Deep link

Arsitektur

Project menggunakan pendekatan feature-first + clean architecture ringan.

```

lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── router/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── home/
│   ├── search/
│   ├── services/
│   ├── provider/
│   ├── booking/
│   ├── chat/
│   ├── reviews/
│   ├── profile/
│   └── admin/
│
├── app.dart
└── main.dart

```

Prinsip utama

UI tidak langsung mengakses database.

Business logic dipisahkan dari widget.

Reusable component diletakkan di core/widgets.

Setiap fitur memiliki data, domain, dan presentation layer.

Query database dibuat terpusat agar mudah dipelihara.

Struktur Folder

Contoh struktur:

jasa_dekat/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── router/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── search/
│   │   ├── services/
│   │   ├── provider/
│   │   ├── booking/
│   │   ├── chat/
│   │   ├── reviews/
│   │   ├── profile/
│   │   └── admin/
│   │
│   ├── app.dart
│   └── main.dart
│
├── supabase/
│   ├── migrations/
│   ├── seed.sql
│   └── config.toml
│
├── test/
├── .env.example
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── LICENSE

Database

Database utama menggunakan PostgreSQL melalui Supabase.

ERD Sederhana

profiles
   │
   ├──────────────< services
   │                    │
   │                    └──────────────< bookings
   │                                         │
   │                                         └──── reviews
   │
   ├──────────────< bookings
   │
   └──────────────< reports

bookings
   │
   └──────────────< messages

Tabel Utama

profiles

Menyimpan informasi pengguna.

Column

Type

Description

id

uuid

ID user

role

text

customer/provider/admin

full_name

text

Nama

avatar_url

text

Foto profil

bio

text

Deskripsi

phone

text

Nomor kontak

latitude

double precision

Latitude

longitude

double precision

Longitude

address_area

text

Area umum

created_at

timestamp

Waktu dibuat

updated_at

timestamp

Waktu diperbarui

categories

Kategori layanan.

Column

Type

Description

id

uuid

ID kategori

name

text

Nama kategori

slug

text

Slug

icon

text

Icon

created_at

timestamp

Waktu dibuat

Contoh kategori:

Pendidikan

Teknologi

Desain

Foto & Video

Rumah Tangga

Reparasi

Event

Freelance

services

Layanan yang ditawarkan provider.

Column

Type

Description

id

uuid

ID layanan

provider_id

uuid

Pemilik layanan

category_id

uuid

Kategori

title

text

Nama layanan

description

text

Deskripsi

price_from

numeric

Harga mulai

price_to

numeric

Harga maksimal

duration_minutes

integer

Estimasi pengerjaan

is_active

boolean

Status layanan

created_at

timestamp

Waktu dibuat

updated_at

timestamp

Waktu diperbarui

bookings

Data pemesanan.

Column

Type

Description

id

uuid

ID booking

customer_id

uuid

Pemesan

provider_id

uuid

Penyedia

service_id

uuid

Layanan

status

text

Status booking

scheduled_at

timestamp

Jadwal

note

text

Catatan

final_price

numeric

Harga akhir

created_at

timestamp

Waktu dibuat

updated_at

timestamp

Waktu diperbarui

Status:

pending
accepted
rejected
in_progress
completed
cancelled

reviews

Rating dan ulasan.

Column

Type

Description

id

uuid

ID review

booking_id

uuid

Booking

reviewer_id

uuid

Pemberi review

provider_id

uuid

Provider

rating

integer

1-5

comment

text

Ulasan

created_at

timestamp

Waktu dibuat

messages

Pesan chat.

Column

Type

Description

id

uuid

ID pesan

booking_id

uuid

Booking

sender_id

uuid

Pengirim

message

text

Isi pesan

created_at

timestamp

Waktu dibuat

read_at

timestamp

Waktu dibaca

reports

Laporan pengguna.

Column

Type

Description

id

uuid

ID laporan

reporter_id

uuid

Pelapor

target_user_id

uuid

User yang dilaporkan

booking_id

uuid

Booking terkait

reason

text

Alasan

description

text

Detail laporan

status

text

Status penanganan

created_at

timestamp

Waktu dibuat

Persiapan Development

Sebelum menjalankan project, install:

Flutter SDK

Dart SDK

Android Studio atau VS Code

Android SDK

Git

Akun Supabase

Cek instalasi:

flutter doctor

Pastikan tidak ada masalah kritis pada environment.

Instalasi

Clone repository:

git clone https://github.com/USERNAME/jasa-dekat.git
cd jasa-dekat

Install dependency:

flutter pub get

Buat file environment:

cp .env.example .env

Isi konfigurasi Supabase pada .env.

Setelah database dan environment siap, jalankan:

flutter run

Environment Variables

Buat file .env:

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

Contoh .env.example:

SUPABASE_URL=
SUPABASE_ANON_KEY=

Catatan keamanan

Jangan commit file .env.

Pastikan .gitignore berisi:

.env
.env.*
!.env.example

Gunakan credential publik yang memang ditujukan untuk client application. Secret key dan service-role key tidak boleh ditanam di aplikasi mobile.

Menyiapkan Supabase

1. Buat Project

Buat project baru di Supabase.

2. Jalankan Migration

Migration database disimpan di:

supabase/migrations/

Dengan Supabase CLI, migration dapat dijalankan menggunakan workflow CLI project.

3. Aktifkan Authentication

Gunakan:

Authentication → Providers → Email

Provider lain dapat ditambahkan kemudian.

4. Storage

Bucket yang direncanakan:

avatars
service-images
portfolio
chat-attachments

Atur policy storage agar user hanya dapat mengakses file yang memang diizinkan.

5. Row Level Security

Aktifkan RLS pada tabel yang berisi data pengguna.

Prinsip dasarnya:

Customer:
- dapat membaca data publik provider
- dapat membuat booking untuk dirinya sendiri
- dapat membaca booking miliknya

Provider:
- dapat mengelola profil sendiri
- dapat mengelola service miliknya
- dapat membaca booking yang masuk ke dirinya

Admin:
- memiliki akses moderasi sesuai policy admin

Jangan mengandalkan pembatasan akses hanya dari sisi Flutter.

Menjalankan Project

Mode development:

flutter run

Melihat device:

flutter devices

Menjalankan analyzer:

flutter analyze

Menjalankan test:

flutter test

Format code:

dart format .

Build Release

Android APK

flutter build apk --release

Output umumnya tersedia pada:

build/app/outputs/flutter-apk/app-release.apk

Android App Bundle

Untuk distribusi melalui Google Play:

flutter build appbundle --release

iOS

flutter build ios --release

Build iOS membutuhkan environment Apple yang sesuai.

Design Guidelines

JasaDekat menggunakan prinsip desain:

Sederhana

Pengguna harus dapat menemukan jasa tanpa melewati terlalu banyak langkah.

Terpercaya

Informasi provider, rating, review, dan status booking harus jelas.

Lokal

Lokasi menjadi salah satu komponen utama discovery.

Konsisten

Gunakan komponen UI reusable agar tampilan antar halaman tetap konsisten.

Status Booking

State machine sederhana:

pending
   ├── accepted
   │      └── in_progress
   │              └── completed
   │
   └── rejected

pending ───────────────→ cancelled
accepted ──────────────→ cancelled
in_progress ───────────→ cancelled

Validasi perubahan status harus dilakukan di backend/database layer, bukan hanya dari UI.

Search dan Ranking

Urutan hasil pencarian dapat dikembangkan menjadi:

score =
  distance_score
  + rating_score
  + completed_order_score
  + availability_score

Versi MVP dapat menggunakan sorting sederhana:

Jarak terdekat.

Rating tertinggi.

Jumlah pesanan selesai.

Harga sesuai filter.

Pada versi lanjutan, ranking dapat dipersonalisasi berdasarkan histori pencarian dan interaksi pengguna.

Monetisasi

Beberapa opsi monetisasi yang dapat dikembangkan:

Commission

Platform mengambil persentase dari transaksi.

Featured Service

Provider dapat membayar agar layanan ditampilkan lebih tinggi.

Subscription

Provider mendapatkan fitur tambahan melalui paket berlangganan.

Business Account

UMKM atau bisnis dapat memperoleh halaman bisnis dan tools tambahan.

Monetisasi pembayaran online tidak wajib untuk MVP. Tahap awal dapat fokus pada validasi kebutuhan dan alur pemesanan.

Roadmap

Phase 1 — MVP

Authentication

Profile

Role customer/provider

Category

Service CRUD

Search

Filter

Basic location

Booking

Booking status

Rating & review

Phase 2 — Engagement

Chat realtime

Push notification

Portfolio provider

Favorite provider

Improved search

Report user

Provider verification

Phase 3 — Trust & Scale

Identity verification workflow

Fraud detection

Provider badge

Analytics dashboard

Dispute management

Better recommendation engine

Phase 4 — Monetization

Payment gateway

Platform commission

Featured service

Subscription

Business account

Testing

Minimal testing yang disarankan:

Unit Test

Untuk:

Validation

Repository

Service

Business rules

Search ranking

Widget Test

Untuk:

Login

Search

Service detail

Booking form

Profile

Integration Test

Untuk alur:

Register
→ Create Service
→ Search Service
→ Create Booking
→ Accept Booking
→ Complete Booking
→ Submit Review

Definition of Done

Sebuah fitur dianggap selesai ketika:

UI sudah dibuat.

Loading state tersedia.

Empty state tersedia.

Error state tersedia.

Validation tersedia.

Data tersimpan dengan benar.

RLS/policy sudah diperiksa.

Tidak ada error analyzer.

Test terkait sudah dijalankan.

Tidak merusak fitur existing.

Konvensi Commit

Gunakan Conventional Commits.

Format:

type(scope): description

Contoh:

feat(auth): add email login
feat(service): add create service form
feat(booking): add booking status flow
fix(search): fix location filter
fix(auth): handle invalid credentials
refactor(profile): simplify profile repository
docs(readme): update installation guide
test(booking): add booking repository tests
chore(deps): update flutter dependencies

Git Workflow

Branch utama:

main

Branch development:

develop

Feature branch:

feature/<nama-fitur>

Contoh:

git checkout -b feature/service-search

Setelah selesai:

git add .
git commit -m "feat(search): add service search"
git push origin feature/service-search

Gunakan Pull Request untuk menggabungkan feature ke branch development atau main sesuai workflow project.

Keamanan dan Privasi

JasaDekat memproses beberapa jenis data pengguna seperti profil, lokasi area, pesan, booking, dan review.

Prinsip keamanan:

Jangan menyimpan secret key di mobile app.

Gunakan Supabase RLS.

Validasi input di client dan server/database layer.

Jangan menampilkan alamat pribadi secara detail.

Batasi akses chat berdasarkan relasi pengguna dengan booking/conversation.

Batasi upload file berdasarkan tipe dan ukuran.

Sediakan mekanisme report.

Hindari menyimpan data yang tidak dibutuhkan.

Gunakan HTTPS/TLS melalui layanan backend yang mendukungnya.

Jangan percaya data dari client tanpa validasi backend.

Kontribusi

Kontribusi dipersilakan.

Workflow:

Fork repository
    ↓
Create branch
    ↓
Make changes
    ↓
Run formatter
    ↓
Run analyzer
    ↓
Run tests
    ↓
Commit
    ↓
Push
    ↓
Create Pull Request

Sebelum membuat Pull Request:

dart format .
flutter analyze
flutter test

Pastikan tidak ada perubahan yang tidak berkaitan dengan fitur yang dikerjakan.

License

Project ini menggunakan lisensi MIT.

Lihat file LICENSE untuk informasi lengkap.

Kontak

Project:

JasaDekat

Repository:

https://github.com/USERNAME/jasa-dekat

Developer:

Nama: YOUR_NAME
Email: YOUR_EMAIL

Ganti USERNAME, YOUR_NAME, dan YOUR_EMAIL sebelum repository dipublikasikan.

MVP Scope

Agar project tetap realistis, MVP JasaDekat berfokus pada:

Authentication
      +
Profile
      +
Service Listing
      +
Search & Filter
      +
Location
      +
Booking
      +
Rating & Review

Chat realtime, pembayaran, verifikasi provider, recommendation engine, dan fitur monetisasi dapat dikembangkan setelah alur utama berhasil divalidasi.

Project Vision

JasaDekat tidak hanya ingin menjadi direktori jasa.

Visi jangka panjangnya adalah membangun infrastruktur marketplace jasa lokal yang membuat skill seseorang lebih mudah ditemukan oleh orang yang membutuhkan bantuan di sekitarnya.

Skill
  ↓
Profile
  ↓
Discovery
  ↓
Trust
  ↓
Booking
  ↓
Service
  ↓
Review
  ↓
Reputation
  ↓
More Opportunities

