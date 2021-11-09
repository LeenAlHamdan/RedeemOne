import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/category.dart';
import 'package:redeem_one/providers/item_provider.dart';
import 'package:redeem_one/widgets/category_item_grid_view.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  CategoryScreen({
    required this.category,
  });
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                AppBar().preferredSize.height,
            child: Consumer<ItemProvider>(
              builder: (_, itemProvider, __) {
                return CategoryItemGridView(
                  title: widget.category.title,
                  items: itemProvider.items
                      .where(
                          (element) => element.categoryId == widget.category.id)
                      .toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
