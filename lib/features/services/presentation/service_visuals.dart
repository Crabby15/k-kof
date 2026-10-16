import 'package:flutter/material.dart';

import '../domain/service_item.dart';

class ServiceVisuals {
  const ServiceVisuals({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

ServiceVisuals serviceVisuals(ServiceItem service) =>
    switch (service.category) {
      'Teknologi' => const ServiceVisuals(
          icon: Icons.laptop_mac_rounded,
          color: Color(0xFFE8EEFF),
        ),
      'Pendidikan' => const ServiceVisuals(
          icon: Icons.menu_book_rounded,
          color: Color(0xFFFFF1DF),
        ),
      'Desain' => const ServiceVisuals(
          icon: Icons.brush_rounded,
          color: Color(0xFFFFE9ED),
        ),
      _ => const ServiceVisuals(
          icon: Icons.home_repair_service_rounded,
          color: Color(0xFFE6F7EF),
        ),
    };
