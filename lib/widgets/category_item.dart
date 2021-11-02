// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/iteme.dart';
import 'package:redeem_one/providers/item_provider.dart';
import 'package:redeem_one/screens/web_view_screen.dart';

class CategoryItem extends StatelessWidget {
  final Item item;

  CategoryItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        itemProvider.clicksItem(item.id);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return WebViewScreen(title: item.title, url: item.link);
          }),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        color: Colors.grey[100],
        margin: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  item.logo,
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              child: Container(
                width: 60,
                height: 20,
                color: Colors.black54,
                padding: const EdgeInsets.all(5),
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
