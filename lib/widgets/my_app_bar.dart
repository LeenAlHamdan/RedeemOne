// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/screens/add_site_screen.dart';
import 'package:redeem_one/screens/splash_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function stopWatch;
  // ignore: prefer_const_constructors_in_immutables
  MyAppBar(this.stopWatch);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    return AppBar(
      title: Row(
        children: const [
          Icon(Icons.lightbulb),
          SizedBox(
            width: 5,
          ),
          Text('RedeemOne'),
        ],
      ),
      actions: [
        userProvider.isAdmin()
            ? IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AddSiteScreen.routeName),
                icon: const Icon(Icons.add),
              )
            : Container(),
        PopupMenuButton(
          onSelected: (value) async {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (cox) => SplashScreen()));
            int val = stopWatch() as int;
            await userProvider.setTodayHoures(val / 3600);
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            userProvider.signOut();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              child: Text('Log Out'),
              value: 1,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
