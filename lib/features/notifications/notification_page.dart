import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bookingNotificationKey = 'jasa_dekat.notifications.v1';

Future<void> saveBookingNotification(String serviceName) async {
  final preferences = await SharedPreferences.getInstance();
  final notices = preferences.getStringList(bookingNotificationKey) ?? [];
  notices.insert(
      0,
      jsonEncode({
        'title': 'Pesanan berhasil dibuat',
        'body': 'Permintaan $serviceName tersimpan dan menunggu konfirmasi.',
        'time': DateTime.now().toIso8601String(),
      }));
  await preferences.setStringList(
      bookingNotificationKey, notices.take(30).toList());
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<String>> _notices;

  @override
  void initState() {
    super.initState();
    _notices = _load();
  }

  Future<List<String>> _load() async =>
      (await SharedPreferences.getInstance())
          .getStringList(bookingNotificationKey) ??
      [];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifikasi')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: FutureBuilder<List<String>>(
              future: _notices,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Notifikasi gagal dimuat.'));
                  }
                  return const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Memuat notifikasi...'),
                    ]),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada notifikasi.'));
                }
                return ListView(
                  children: snapshot.data!.map((raw) {
                    final notice = jsonDecode(raw) as Map<String, dynamic>;
                    return ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.event_available)),
                      title: Text(notice['title'] as String),
                      subtitle: Text(
                          '${notice['body']}\n${DateTime.parse(notice['time'] as String).toLocal()}'),
                      isThreeLine: true,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );
}
