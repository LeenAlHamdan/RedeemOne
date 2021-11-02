class User {
  final String id;
  final String fullName;
  final bool isAdmin;

  User({
    required this.id,
    required this.fullName,
    this.isAdmin = false,
  });
}
