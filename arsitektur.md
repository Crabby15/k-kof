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
