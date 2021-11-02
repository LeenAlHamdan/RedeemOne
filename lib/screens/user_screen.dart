// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/http_exception.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/screens/splash_screen.dart';
import 'package:redeem_one/widgets/category_item_grid_view.dart';

import '../error_dialog.dart';
import '../models/page_item.dart';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../providers/page_item_provider.dart';
import '../screens/page_screen.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/navigator_widget.dart';

class UserScreen extends StatefulWidget {
  static const routeName = '/userScreen';
  final Function? stopTimer;

  UserScreen([this.stopTimer]);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _scrollController = ScrollController();
  var _isInit = true;
  var _isLoading = false;

  void scrollTo(GlobalKey<State<StatefulWidget>> key) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        setState(() {
          Scrollable.ensureVisible(key.currentContext!);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    /*  final key = ModalRoute.of(context)!.settings.arguments as Category?;
 if (key != null) {

                  scrollTo(key.key);
                } */
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        Future.delayed(Duration.zero).then((value) => {
              Provider.of<PageItemProvider>(context, listen: false)
                  .fetchAndSetPageItems(),
              Provider.of<CategoryProvider>(context, listen: false)
                  .fetchAndSetCategories(),
              Provider.of<ItemProvider>(context, listen: false)
                  .fetchAndSetItems()
                  .then((_) {
                setState(() {
                  _isLoading = false;
                });
              }),
            });
      } on HttpException catch (_) {
        const errorMessage = 'Something went wrong!.try again later';
        showErrorDialog(errorMessage, context);
      } catch (error) {
        const errorMessage = 'Something went wrong!.try again later';
        showErrorDialog(errorMessage, context);
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> _refreshProducts() async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false)
          .fetchAndSetCategories();
      await Provider.of<ItemProvider>(context, listen: false)
          .fetchAndSetItems();
      await Provider.of<ItemProvider>(context, listen: false).getTodayClicks();
    } on HttpException catch (_) {
      const errorMessage = 'Something went wrong!.try again later';
      showErrorDialog(errorMessage, context);
    } catch (error) {
      const errorMessage = 'Something went wrong!.try again later';
      showErrorDialog(errorMessage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final _isAdmin = userProv.isAdmin();

    /*   return Consumer<UserProvider>(
      builder: (_, user, __) {
        if (user.userIsSignd()) { */
    return Scaffold(
      appBar: MyAppBar(widget.stopTimer!),
      primary: true,
      drawer: NavigatorWidget(
        /*  scrollToIndex: (Category k) {
          scrollTo(k.key);
        }, */
        openPage: (PageItem pageItem) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return PageScreen(pageItem.id);
          }),
        ),
        stopWatch: widget.stopTimer!,
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
          : WillPopScope(
              onWillPop: () async {
                if (Navigator.canPop(context)) return true;
                final value = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('We will miss you'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              'stay',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (cox) => SplashScreen()));
                              int val = widget.stopTimer!() as int;
                              await userProv.setTodayHoures(val / 3600);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              'exit',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      );
                    });

                return value == true;
              },
              child: RefreshIndicator(
                onRefresh: () => _refreshProducts(),
                child: SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Card(
                      color: Colors.grey[300],
                      elevation: 15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Image(
                              image: AssetImage('assets/images/logo.png'),
                              height: 150,
                              width: double.infinity,
                            ),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Consumer<CategoryProvider>(
                                builder: (_, catProvider, __) {
                                  return Column(
                                    children: catProvider.categories.map((e) {
                                      var index =
                                          catProvider.categories.indexOf(e);
                                      return Container(
                                        key: e.key,
                                        child: Consumer<ItemProvider>(
                                          builder: (_, itemProvider, __) {
                                            return CategoryItemGridView(
                                              title: catProvider
                                                  .categories[index].title,
                                              items: itemProvider.items
                                                  .where((element) =>
                                                      element.categoryId ==
                                                      catProvider
                                                          .categories[index].id)
                                                  .toList(),
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
    /*  } else {
          Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Signed Out'), duration: Duration(seconds: 2)),
          );
          return Scaffold(
            body: Container(),
          );
        } */
    // },
    // );
  }
}
