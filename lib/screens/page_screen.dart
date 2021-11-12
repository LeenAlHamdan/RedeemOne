// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:redeem_one/screens/web_view_screen.dart';

import 'package:provider/provider.dart';
import 'package:redeem_one/models/page_item.dart';
import 'package:redeem_one/providers/page_item_provider.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/screens/add_new_page.dart';

class PageScreen extends StatefulWidget {
  final String pageItemId;

  PageScreen(this.pageItemId);

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  final titleController = TextEditingController();

  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var pageProvider = Provider.of<PageItemProvider>(context);

    PageItem pageItem = pageProvider.findById(widget.pageItemId);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageItem.title),
        actions: [
          userProvider.isAdmin()
              ? IconButton(
                  onPressed: () => Navigator.of(context)
                          .pushNamed(AddNewPage.routeName, arguments: {
                        'page': pageItem,
                      }),
                  icon: const Icon(Icons.edit))
              : Container(),
          userProvider.isAdmin()
              ? IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AddNewPage.routeName),
                  icon: const Icon(Icons.add))
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    pageItem.content,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pageItem.link != null && pageItem.link != ''
                        ? Linkify(
                            onOpen: (_) =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => WebViewScreen(
                                url: pageItem.link!,
                                title: pageItem.title,
                              ),
                            )),
                            text: pageItem.link!,
                          )
                        : Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pageItem.image != null && pageItem.image != ''
                        ? Image.network(
                            pageItem.image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(),
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
