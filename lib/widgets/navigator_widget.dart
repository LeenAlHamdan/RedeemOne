// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/providers/category_provider.dart';
import 'package:redeem_one/providers/page_item_provider.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/screens/add_site_screen.dart';
import 'package:redeem_one/screens/category_screen.dart';
import 'package:redeem_one/screens/splash_screen.dart';
import 'package:redeem_one/screens/user_profile_screen.dart';
import 'package:redeem_one/screens/user_screen.dart';

class NavigatorWidget extends StatelessWidget {
  final Function openPage;
  final Function stopWatch;

  NavigatorWidget({
    required this.openPage,
    required this.stopWatch,
  });

  Widget buildHeader(bool isInUserScreen, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);

        isInUserScreen
            ? Navigator.of(context).pushNamed(UserProfileScreen.routeName)
            : Navigator.pop(context);
        isInUserScreen = !isInUserScreen;
      },
      child: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.lightbulb),
            Text(
              isInUserScreen ? 'Profile' : 'Home',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*  void scroll(Category key, BuildContext context) {
    Navigator.of(context).pop();
    scrollToIndex(key);
  } */

  @override
  Widget build(BuildContext context) {
    var setting = ModalRoute.of(context)?.settings;
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var catProvider = Provider.of<CategoryProvider>(context, listen: false);
    var pagesProvider = Provider.of<PageItemProvider>(context, listen: false);
    bool isInUserScreen =
        setting?.name == UserScreen.routeName || setting?.name == '/';
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //header
            buildHeader(isInUserScreen, context),
            const Divider(),
            //first section
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10, left: 5),
                  child: const Text(
                    'Cateories',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                ...catProvider.categories
                    .map((e) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (cox) =>
                                      CategoryScreen(category: e))),
                          /* scroll(
                            e,
                            context,
                          ), */
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
            //second section
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10, left: 5),
                  child: const Text(
                    'Pages',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                ...pagesProvider.items
                    .map((e) => GestureDetector(
                          onTap: () {
                            openPage(e);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
            const Divider(),
            //adminestraor
            (userProvider.isAdmin())
                ? TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AddSiteScreen.routeName),
                    icon:
                        Icon(Icons.add, color: Theme.of(context).primaryColor),
                    label: Text(
                      'Add Site',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                : Container(),
            //logout section
            GestureDetector(
              onTap: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (cox) => SplashScreen()));
                int val = stopWatch() as int;

                await userProvider.setTodayHoures(val / 3600);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                userProvider.signOut();
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
