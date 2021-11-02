// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/category.dart';

import '../error_dialog.dart';
import '../models/http_exception.dart';
import '../models/page_item.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import '../screens/page_screen.dart';
import '../screens/user_screen.dart';
import '../widgets/badge.dart';
import '../widgets/category_item.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/navigator_widget.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/userProfile';
  final Function stopTimer;

  // ignore: prefer_const_constructors_in_immutables
  UserProfileScreen(this.stopTimer);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var _isLoading = false;
  var isInit = true;
  var _slectedFilter = [
    true,
    false,
    false,
    false,
  ];

  var _slectedFilter2 = [
    true,
    false,
    false,
    false,
  ];

  Future<void> _refreshItems(BuildContext context) async {
    await Provider.of<ItemProvider>(context, listen: false).fetchAndSetItems();
    await Provider.of<ItemProvider>(context, listen: false).getTodayClicks();
  }

  Widget _bulidSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _bulidFilterCard(String title, Function onFilter, bool isSlected) {
    return GestureDetector(
      onTap: () => onFilter(),
      child: Card(
        color: isSlected ? Theme.of(context).primaryColorDark : Colors.white,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              color: isSlected ? Colors.white : Colors.black,
            ),
          ),
        ),
        shape: const StadiumBorder(
          side: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters1() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bulidFilterCard('Today', () {
              setState(() {
                _isLoading = true;
              });
              try {
                Provider.of<ItemProvider>(context, listen: false)
                    .getTodayClicks()
                    .then((value) => setState(() {
                          _isLoading = false;
                          _slectedFilter = [
                            true,
                            false,
                            false,
                            false,
                          ];
                        }));
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);
                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);
                setState(() {
                  _isLoading = false;
                });
                return;
              }
            }, _slectedFilter[0]),
            _bulidFilterCard('Week', () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<ItemProvider>(context, listen: false)
                    .clicksItemCount(
                  DateTime.now().subtract(const Duration(days: 7)),
                  DateTime.now(),
                );
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (error) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              }
              setState(() {
                _isLoading = false;
                _slectedFilter = [
                  false,
                  true,
                  false,
                  false,
                ];
              });
            }, _slectedFilter[1]),
            _bulidFilterCard('Date To Date', () async {
              DateTime? last = DateTime.now();
              final DateTime? first = await showDialog(
                  context: context,
                  builder: (ctx) => DatePickerDialog(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 5 * 360)),
                        lastDate: DateTime.now(),
                        helpText: 'From',
                      ));
              if (first == null) return;
              if (first.day == last.day &&
                  first.month == last.month &&
                  first.year == last.year) {
                setState(() {
                  _isLoading = true;
                  _slectedFilter = [
                    true,
                    false,
                    false,
                  ];
                });
                try {
                  await Provider.of<ItemProvider>(context, listen: false)
                      .clicksItemCount(first, first);
                } on HttpException catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                } catch (error) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
              } else {
                last = await showDialog(
                    context: context,
                    builder: (ctx) => DatePickerDialog(
                          initialDate: first,
                          firstDate: first,
                          lastDate: DateTime.now(),
                          helpText: 'To',
                        ));
                if (last == null) return;

                setState(() {
                  _isLoading = true;
                });

                try {
                  if (first.day == last.day &&
                      first.month == last.month &&
                      first.year == last.year) {
                    await Provider.of<ItemProvider>(context, listen: false)
                        .clicksItemCount(first, first);
                  } else {
                    await Provider.of<ItemProvider>(context, listen: false)
                        .clicksItemCount(first, last);
                  }
                } on HttpException catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                } catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
              }
              setState(() {
                _isLoading = false;
                _slectedFilter = [
                  false,
                  false,
                  true,
                  false,
                ];
              });
            }, _slectedFilter[2]),
            _bulidFilterCard('Particular Date', () async {
              final DateTime picked = await showDialog(
                  context: context,
                  builder: (ctx) => DatePickerDialog(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 5 * 360)),
                        lastDate: DateTime.now(),
                      ));

              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<ItemProvider>(context, listen: false)
                    .clicksItemCount(picked, picked);
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              }
              setState(() {
                _isLoading = false;
                _slectedFilter = [
                  false,
                  false,
                  false,
                  true,
                ];
              });
            }, _slectedFilter[3]),
          ],
        ));
  }

  Widget _buildFilters2() {
    final userPov = Provider.of<UserProvider>(context, listen: false);
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bulidFilterCard('Today', () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await userPov.getTodayHoures().then((value) => setState(() {
                      _isLoading = false;
                      _slectedFilter2 = [
                        true,
                        false,
                        false,
                        false,
                      ];
                    }));
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              }
            }, _slectedFilter2[0]),
            _bulidFilterCard('Week', () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await userPov.getHoures(
                  DateTime.now().subtract(const Duration(days: 7)),
                  DateTime.now(),
                );
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (error) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              }
              setState(() {
                _isLoading = false;
                _slectedFilter2 = [
                  false,
                  true,
                  false,
                  false,
                ];
              });
            }, _slectedFilter2[1]),
            _bulidFilterCard('Date To Date', () async {
              DateTime last = DateTime.now();
              final DateTime first = await showDialog(
                  context: context,
                  builder: (ctx) => DatePickerDialog(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 5 * 360)),
                        lastDate: DateTime.now(),
                        helpText: 'From',
                      ));

              if (first.day == last.day &&
                  first.month == last.month &&
                  first.year == last.year) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await userPov.getHoures(first, first);
                } on HttpException catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                } catch (error) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
              } else {
                last = await showDialog(
                    context: context,
                    builder: (ctx) => DatePickerDialog(
                          initialDate: first,
                          firstDate: first,
                          lastDate: DateTime.now(),
                          helpText: 'To',
                        ));

                setState(() {
                  _isLoading = true;
                });

                try {
                  await userPov.getHoures(first, last);
                } on HttpException catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                } catch (_) {
                  const errorMessage =
                      'Something went wrong. \n try again later';
                  showErrorDialog(errorMessage, context);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
              }
              setState(() {
                _isLoading = false;
                _slectedFilter2 = [
                  false,
                  false,
                  true,
                  false,
                ];
              });
            }, _slectedFilter2[2]),
            _bulidFilterCard('Particular Date', () async {
              final DateTime picked = await showDialog(
                  context: context,
                  builder: (ctx) => DatePickerDialog(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 5 * 360)),
                        lastDate: DateTime.now(),
                      ));

              setState(() {
                _isLoading = true;
              });
              try {
                await userPov.getHoures(picked, picked);
              } on HttpException catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              } catch (_) {
                const errorMessage = 'Something went wrong. \n try again later';
                showErrorDialog(errorMessage, context);

                setState(() {
                  _isLoading = false;
                });
                return;
              }
              setState(() {
                _isLoading = false;
                _slectedFilter2 = [
                  false,
                  false,
                  false,
                  true,
                ];
              });
            }, _slectedFilter2[3]),
          ],
        ));
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        Future.delayed(Duration.zero).then((value) => {
              Provider.of<ItemProvider>(context, listen: false)
                  .getTodayClicks()
                  .then((value) {
                setState(() {
                  _isLoading = false;
                });
              }),
              setState(() {
                _isLoading = true;
              }),
              Provider.of<UserProvider>(context, listen: false)
                  .getTodayHoures()
                  .then((value) {
                setState(() {
                  _isLoading = false;
                });
              }),
            });
      } on HttpException catch (_) {
        setState(() {
          _isLoading = false;
        });
        const errorMessage = 'Something went wrong!.try again later';
        showErrorDialog(errorMessage, context);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        const errorMessage = 'Something went wrong!.try again later';
        showErrorDialog(errorMessage, context);
      }
    }
    super.didChangeDependencies();
  }

  void scrollTo(Category key) {
    Navigator.of(context).pop();
    Navigator.of(context)
        .pushReplacementNamed(UserScreen.routeName, arguments: key);
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(widget.stopTimer),
      drawer: NavigatorWidget(
        //   scrollToIndex: scrollTo,
        openPage: (PageItem pageItem) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return PageScreen(pageItem.id);
          }),
        ),
        stopWatch: widget.stopTimer,
      ),
      body: SafeArea(
        child: _isLoading
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
            : RefreshIndicator(
                onRefresh: () => _refreshItems(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //header
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 100,
                            ),
                            Consumer<UserProvider>(
                              builder: (_, userProvider, __) {
                                return Text(
                                  userProvider.currentUser1.fullName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      //clicks on app
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bulidSectionTitle(
                              'User Click On Particular App',
                            ),
                            _buildFilters1(),
                            Consumer<ItemProvider>(
                                builder: (_, itemProvider, __) {
                              final items = itemProvider.items;
                              return Scrollbar(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: (MediaQuery.of(context).size.height -
                                          MediaQuery.of(context).padding.top -
                                          150) *
                                      0.2,
                                  child: GridView.builder(
                                      itemCount: items.length,
                                      padding: const EdgeInsets.all(25.0),
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 100,
                                        mainAxisExtent: 100,
                                        childAspectRatio: 3 / 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                      ),
                                      itemBuilder: (cox, index) {
                                        return Badge(
                                          child: CategoryItem(
                                            item: items[index],
                                          ),
                                          value: items[index].clicks,
                                        );
                                      }),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bulidSectionTitle(
                              'Time Spent On App',
                            ),
                            _buildFilters2(),
                            Consumer<UserProvider>(
                              builder: (_, userProvider, __) {
                                final houres = userProvider.userHoures;
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor,
                                    child: FittedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          '$houres hours',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back To Home Page'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
