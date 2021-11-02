class Item {
  final String id;
  final String categoryId;
  final String title;
  final String link;
  final String logo;
  int clicks;

  Item({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.logo,
    required this.link,
    this.clicks = 0,
  });
}
