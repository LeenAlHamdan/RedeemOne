class PageItem {
  final String id;
  final String title;
  final String content;
  final String? image;
  final String? link;

  PageItem(
      {required this.id,
      required this.title,
      required this.content,
      this.link,
      this.image});
}
