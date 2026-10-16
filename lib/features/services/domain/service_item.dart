class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.category,
    required this.title,
    required this.priceLabel,
    required this.rating,
    required this.distance,
  });

  final String id;
  final String category;
  final String title;
  final String priceLabel;
  final double rating;
  final String distance;
}
