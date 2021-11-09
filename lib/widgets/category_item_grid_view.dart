import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/widgets/error_dialog.dart';
import 'package:redeem_one/models/http_exception.dart';
import 'package:redeem_one/models/iteme.dart';
import 'package:redeem_one/providers/item_provider.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/widgets/category_item.dart';

class CategoryItemGridView extends StatelessWidget {
  final String title;
  final List<Item> items;

  CategoryItemGridView({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<UserProvider>(context).isAdmin();
    return Visibility(
      visible: items.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  mainAxisExtent: 100,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (cox, index) {
                  return isAdmin
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CategoryItem(
                              item: items[index],
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              title: Text(
                                                'Confirm Delete',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                              ),
                                              content: Text(
                                                'Are you sure deleting ${items[index].title}?',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              actions: [
                                                GestureDetector(
                                                    onTap: () async {
                                                      Navigator.pop(ctx);

                                                      try {
                                                        final itemProvider =
                                                            Provider.of<
                                                                    ItemProvider>(
                                                                context,
                                                                listen: false);

                                                        await itemProvider
                                                            .deleteItem(
                                                                items[index]
                                                                    .id);
                                                      } on HttpException catch (_) {
                                                        showErrorDialog(
                                                            'Deleting failed!',
                                                            context);
                                                      } catch (_) {
                                                        showErrorDialog(
                                                            'Deleting failed!',
                                                            context);
                                                      }
                                                    },
                                                    child: const Text(
                                                      'delete',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.red),
                                                    )),
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    child: const Text('cancel',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ))),
                                              ],
                                              actionsPadding:
                                                  const EdgeInsets.all(8),
                                            ));
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : CategoryItem(
                          item: items[index],
                        );
                }),
          ),
        ],
      ),
    );
  }
}
