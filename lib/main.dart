import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/screens/rest_password_screen.dart';

import './providers/category_provider.dart';
import './providers/item_provider.dart';
import './providers/page_item_provider.dart';
import './providers/user_provider.dart';
import './screens/add_site_screen.dart';
import './screens/sign_in_screen.dart';
import './screens/sign_up_screen.dart';
import './screens/user_profile_screen.dart';
import './screens/user_screen.dart';
import './screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  final stopwatch = Stopwatch();

  Widget getHome(UserProvider user) {
    if (user.userIsSignd()) {
      stopwatch.start();
      return UserScreen(stopTimer);
    } else {
      return FutureBuilder(
          future: user.tryAutoLogin(),
          builder: (ctx, authResultSnapshot) {
            if (authResultSnapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            } else if (user.userIsSignd()) {
              stopwatch.start();

              return UserScreen(stopTimer);
            } else {
              return SignInScreen();
            }
          });
    }
  }

  int stopTimer() {
    stopwatch.stop();

    return stopwatch.elapsed.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PageItemProvider(),
        ),
        ChangeNotifierProxyProvider<UserProvider, ItemProvider>(
          create: (_) => ItemProvider('', []),
          update: (ctx, user, previousItems) => ItemProvider(
            user.userId,
            previousItems == null ? [] : previousItems.items,
          ),
        ),
        /*   ChangeNotifierProxyProvider<UserProvider, CategoryProvider>(
          create: (_) => CategoryProvider([]),
          update: (ctx, user, previousItems) => CategoryProvider(
            previousItems == null ? [] : previousItems.categories,
          ), */

        /* ChangeNotifierProxyProvider<UserProvider, PageItemProvider>(
          create: (_) => PageItemProvider([]),
          update: (ctx, user, previousItems) => PageItemProvider(
            previousItems == null ? [] : previousItems.items,
          ),
        ), */
      ],
      child: Consumer<UserProvider>(
        builder: (_, user, __) => MaterialApp(
          title: 'RedeemOne',
          theme: ThemeData(
            fontFamily: 'Lato',
            primaryColor: Colors.pink[100],
            primaryColorDark: Colors.deepPurple[200],
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepPurple[300],
            ),
            colorScheme:
                ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
                    .copyWith(secondary: Colors.pink[50]),
          ),
          home: getHome(user),
          routes: {
            UserScreen.routeName: (ctx) => UserScreen(stopTimer),
            AddSiteScreen.routeName: (ctx) => AddSiteScreen(),
            UserProfileScreen.routeName: (ctx) => UserProfileScreen(stopTimer),
            SignInScreen.routeName: (ctx) => SignInScreen(),
            RestPasswordScreen.routeName: (ctx) => RestPasswordScreen(),
            SignUpScreen.routeName: (ctx) => SignUpScreen(),
          },
        ),
      ),
    );
  }
}
