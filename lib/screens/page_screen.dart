// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/page_item.dart';
import 'package:redeem_one/providers/page_item_provider.dart';
import 'package:redeem_one/providers/user_provider.dart';

class PageScreen extends StatefulWidget {
  final String pageItemId;

  PageScreen(this.pageItemId);

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  final titleController = TextEditingController();

  final contentController = TextEditingController();

  bool _isLoading = false;

  Future<void> update(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<PageItemProvider>(context, listen: false).updateItem(
        widget.pageItemId,
        PageItem(
            id: widget.pageItemId,
            title: titleController.text,
            content: contentController.text),
      );
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: const Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Done'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> add(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<PageItemProvider>(context, listen: false).addItem(
        PageItem(
            id: '0',
            title: titleController.text,
            content: contentController.text),
      );
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: const Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Done'), duration: Duration(seconds: 2)),
      );
      Navigator.pop(context);
    }
  }

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
                  onPressed: () {
                    titleController.text = pageItem.title;
                    contentController.text = pageItem.content;
                    showDialog(
                        context: context,
                        builder: (_) {
                          return SimpleDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.edit),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('Edit ${pageItem.title}:'),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  decoration:
                                      const InputDecoration(labelText: 'title'),
                                  controller: titleController,
                                  onSubmitted: (_) => update(context),
                                  autofocus: true,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Content'),
                                  controller: contentController,
                                  keyboardType: TextInputType.multiline,
                                  onSubmitted: (_) => update(context),
                                  autofocus: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        size: 35,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => update(context),
                                      icon: Icon(
                                        Icons.check_circle,
                                        size: 35,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.edit))
              : Container(),
          userProvider.isAdmin()
              ? IconButton(
                  onPressed: () {
                    titleController.text = '';
                    contentController.text = '';
                    showDialog(
                        context: context,
                        builder: (_) {
                          return SimpleDialog(
                            title: Row(
                              children: const [
                                Icon(Icons.add),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Add Page:'),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  decoration:
                                      const InputDecoration(labelText: 'title'),
                                  controller: titleController,
                                  onSubmitted: (_) => add(context),
                                  autofocus: true,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Content'),
                                  controller: contentController,
                                  keyboardType: TextInputType.multiline,
                                  onSubmitted: (_) => add(context),
                                  autofocus: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        size: 35,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => add(context),
                                      icon: Icon(
                                        Icons.check_circle,
                                        size: 35,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.add))
              : Container()
        ],
      ),
      body: _isLoading
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text("Loading...")),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      pageItem.content,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
