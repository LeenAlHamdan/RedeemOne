import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final GlobalKey<State<StatefulWidget>> key;

  Category({required this.id, required this.title, required this.key});
}
