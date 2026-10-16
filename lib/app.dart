import 'package:flutter/material.dart';

import 'features/booking/presentation/booking_page.dart';
import 'features/booking/presentation/booking_list_page.dart';
import 'features/services/data/service_repository.dart';
import 'features/services/domain/service_item.dart';
import 'features/services/presentation/service_search_page.dart';
import 'features/services/presentation/service_visuals.dart';

const _ink = Color(0xFF182B49);
const _blue = Color(0xFF315FEA);
const _pale = Color(0xFFF4F7FC);

class JasaDekatApp extends StatelessWidget {
  const JasaDekatApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'JasaDekat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: _blue),
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _pale,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
        home: const AuthPage(),
      );
}

class _Account {
  const _Account(this.name, this.email, this.password);
  final String name;
  final String email;
  final String password;
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Data demo lives only in memory and resets when the application restarts.
  static final List<_Account> _accounts = [];
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim().toLowerCase();
    final password = _password.text;
    if (_isLogin) {
      for (final account in _accounts) {
        if (account.email == email && account.password == password) {
          _openHome(account.name);
          return;
        }
      }
      _message('Akun tidak ditemukan. Silakan daftar terlebih dahulu.');
      return;
    }
    if (_accounts.any((account) => account.email == email)) {
      _message('Email sudah terdaftar. Silakan masuk.');
      return;
    }
    final name = _name.text.trim();
    _accounts.add(_Account(name, email, password));
    _openHome(name);
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _openHome(String name) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => HomePage(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Brand(),
                  const SizedBox(height: 42),
                  Text(
                      _isLogin
                          ? 'Temukan bantuan\ndi dekatmu.'
                          : 'Mulai bersama\nJasaDekat.',
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                    _isLogin
                        ? 'Masuk dan temukan jasa lokal yang kamu butuhkan.'
                        : 'Buat akun untuk mencari atau menawarkan jasa.',
                    style:
                        const TextStyle(color: Color(0xFF718096), fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  _AuthSwitch(
                      isLogin: _isLogin,
                      onChanged: (value) {
                        setState(() => _isLogin = value);
                      }),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isLogin) ...[
                          const _FieldLabel('Nama lengkap'),
                          TextFormField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                hintText: 'Contoh: Nadia Putri'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                        const _FieldLabel('Email'),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Kata sandi'),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword),
                              icon: Icon(_hidePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                                  ? 'Gunakan minimal 6 karakter'
                                  : null,
                        ),
                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _message(
                                  'Hubungkan reset password saat backend tersedia.'),
                              child: const Text('Lupa kata sandi?'),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                                'Dengan mendaftar, kamu menyetujui ketentuan penggunaan JasaDekat.',
                                style: TextStyle(
                                    color: Color(0xFF718096), fontSize: 12)),
                          ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_isLogin ? 'Masuk' : 'Buat akun',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('Jasa lokal, lebih dekat dan terpercaya.',
                        style:
                            TextStyle(color: Color(0xFF718096), fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: _blue, borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.handyman_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text('JasaDekat',
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w800, color: _ink)),
      ]);
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
      );
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch({required this.isLogin, required this.onChanged});
  final bool isLogin;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: _pale, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          _AuthTab(
              label: 'Masuk', selected: isLogin, onTap: () => onChanged(true)),
          _AuthTab(
              label: 'Daftar',
              selected: !isLogin,
              onTap: () => onChanged(false)),
        ]),
      );
}

class _AuthTab extends StatelessWidget {
  const _AuthTab(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x11000000), blurRadius: 8)]
                  : null,
            ),
            child: Center(
                child: Text(label,
                    style: TextStyle(
                        color: selected ? _ink : const Color(0xFF718096),
                        fontWeight: FontWeight.w700))),
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            children: [
              Row(children: [
                const _Brand(),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded)),
                PopupMenuButton<String>(
                  tooltip: 'Akun',
                  onSelected: (value) {
                    if (value == 'logout') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                            builder: (_) => const AuthPage()),
                        (route) => false,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'logout', child: Text('Keluar'))
                  ],
                  child: CircleAvatar(
                      backgroundColor: const Color(0xFFE8EEFF),
                      child: Text(name.isEmpty ? 'J' : name[0].toUpperCase(),
                          style: const TextStyle(
                              color: _blue, fontWeight: FontWeight.bold))),
                ),
              ]),
              const SizedBox(height: 30),
              Text('Halo, $name 👋',
                  style:
                      const TextStyle(fontSize: 15, color: Color(0xFF718096))),
              const SizedBox(height: 6),
              const Text('Butuh bantuan apa\nhari ini?',
                  style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const ServiceSearchPage()),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari jasa yang kamu butuhkan',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
                ),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BookingPage()),
                ),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Buat pesanan jasa'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: _blue, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Punya keahlian?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                            'Tawarkan jasamu dan temukan pelanggan di sekitarmu.',
                            style: TextStyle(
                                color: Color(0xFFE1E8FF), height: 1.4)),
                      ])),
                  SizedBox(width: 10),
                  Icon(Icons.work_outline_rounded,
                      color: Colors.white, size: 40),
                ]),
              ),
              const SizedBox(height: 26),
              const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kategori populer',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                    Text('Lihat semua',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.w600)),
                  ]),
              const SizedBox(height: 14),
              SizedBox(
                height: 99,
                child:
                    ListView(scrollDirection: Axis.horizontal, children: const [
                  _Category(
                      icon: Icons.laptop_mac_rounded,
                      label: 'Teknologi',
                      color: Color(0xFFE8EEFF)),
                  _Category(
                      icon: Icons.menu_book_rounded,
                      label: 'Pendidikan',
                      color: Color(0xFFFFF1DF)),
                  _Category(
                      icon: Icons.brush_rounded,
                      label: 'Desain',
                      color: Color(0xFFFFE9ED)),
                  _Category(
                      icon: Icons.home_repair_service_rounded,
                      label: 'Rumah',
                      color: Color(0xFFE6F7EF)),
                ]),
              ),
              const SizedBox(height: 22),
              const Text('Rekomendasi untukmu',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 12),
              for (final service in demoServices)
                _ServiceCard(service: service),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (index) {
            if (index == 1) {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const BookingListPage(),
              ));
            }
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
          ],
        ),
      );
}

class _Category extends StatelessWidget {
  const _Category(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 82,
        child: Column(children: [
          Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: _ink)),
          const SizedBox(height: 7),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final ServiceItem service;
  @override
  Widget build(BuildContext context) {
    final visuals = serviceVisuals(service);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEDF0F5))),
      child: Row(children: [
        Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: visuals.color, borderRadius: BorderRadius.circular(15)),
            child: Icon(visuals.icon, color: _ink)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(service.category,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
          const SizedBox(height: 3),
          Text(service.title,
              style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 4),
          const Row(children: [
            Icon(Icons.star_rounded, color: Color(0xFFFFB547), size: 15),
            Text(' 4.9  ·  2.1 km',
                style: TextStyle(fontSize: 11, color: Color(0xFF718096)))
          ]),
        ])),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => BookingPage(initialService: service)),
          ),
          child: const Text('Pesan'),
        ),
      ]),
    );
  }
}
