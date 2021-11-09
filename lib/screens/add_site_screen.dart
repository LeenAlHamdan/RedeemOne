// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/category.dart';
import 'package:redeem_one/models/iteme.dart';
import 'package:redeem_one/providers/category_provider.dart';
import 'package:redeem_one/providers/item_provider.dart';

class AddSiteScreen extends StatefulWidget {
  static const routeName = '/addSite';

  @override
  State<AddSiteScreen> createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends State<AddSiteScreen> {
  final _linkFocusNode = FocusNode();
  final _catFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _catController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String? _dropdownValue;
  List<Category> _spinnerItems = [];

  bool _isLoading = false;
  bool newCat = false;

  late Item _editedItem = Item(
    id: '',
    categoryId: '',
    title: '',
    logo: '',
    link: '',
  );

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _linkFocusNode.dispose();
    _imageUrlController.dispose();

    _catController.dispose();
    _catFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (_dropdownValue == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please Choose category'),
            duration: Duration(seconds: 2)),
      );
      return;
    }
    /*  if (_editedItem.categoryId == '') {
    
    } */
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_dropdownValue == '-1') {
        final catId =
            await Provider.of<CategoryProvider>(context, listen: false)
                .addCategory(Category(id: '', title: _catController.text));
        _editedItem = Item(
            id: _editedItem.id,
            categoryId: catId,
            title: _editedItem.title,
            logo: _editedItem.logo,
            link: _editedItem.link);
      }
      await Provider.of<ItemProvider>(context, listen: false)
          .addItem(_editedItem);
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Site'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Loading...",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    //Title input
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      cursorColor: Theme.of(context).primaryColorDark,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_linkFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedItem = Item(
                          title: value!,
                          link: _editedItem.link,
                          logo: _editedItem.logo,
                          id: _editedItem.id,
                          categoryId: _editedItem.categoryId,
                        );
                      },
                    ),
                    //category process
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Consumer<CategoryProvider>(
                        builder: (_, catProvider, __) {
                          _spinnerItems = catProvider.categories;
                          _spinnerItems.add(Category(id: '-1', title: 'Other'));
                          if (_spinnerItems.isEmpty) {
                            return Container();
                          } else {
                            //     _dropdownValue = _spinnerItems[0].id;
                            return DropdownButton<String>(
                              isExpanded: true,
                              value: _dropdownValue,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              iconSize: 24,
                              hint: Text(
                                'Category',
                                style: TextStyle(color: Colors.white),
                              ),
                              elevation: 16,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              underline: Container(
                                height: 3,
                                color: Theme.of(context).primaryColor,
                              ),
                              onChanged: (data) {
                                setState(() {
                                  _dropdownValue = data!;
                                });
                                if (_dropdownValue != '-1') {
                                  _editedItem = Item(
                                    title: _editedItem.title,
                                    link: _editedItem.link,
                                    logo: _editedItem.logo,
                                    id: _editedItem.id,
                                    categoryId: _dropdownValue!,
                                  );
                                  FocusScope.of(context)
                                      .requestFocus(_linkFocusNode);
                                } else {
                                  setState(() {
                                    newCat = true;
                                  });
                                  FocusScope.of(context)
                                      .requestFocus(_catFocusNode);
                                }
                              },
                              items: _spinnerItems
                                  .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value.id,
                                  child: Text(value.title),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ),
                    Visibility(
                      visible: newCat,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Theme.of(context).primaryColorDark,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 3,
                                color: Theme.of(context).primaryColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 3,
                                color: Theme.of(context).primaryColorDark),
                          ),
                          labelText: 'Category title',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        textInputAction: TextInputAction.next,
                        controller: _catController,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_linkFocusNode);
                        },
                        focusNode: _catFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          FocusScope.of(context).requestFocus(_linkFocusNode);
                        },
                      ),
                    ),
                    //Link input
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Theme.of(context).primaryColorDark,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        labelText: 'Link',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.url,
                      focusNode: _linkFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a link.';
                        }
                      },
                      onSaved: (value) {
                        _editedItem = Item(
                          title: _editedItem.title,
                          link: value!,
                          logo: _editedItem.logo,
                          id: _editedItem.id,
                          categoryId: _editedItem.categoryId,
                        );
                      },
                    ),
                    //Image process
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Enter a URL',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            cursorColor: Theme.of(context).primaryColorDark,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 3),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark,
                                    width: 3),
                              ),
                              labelText: 'Image URL',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedItem = Item(
                                title: _editedItem.title,
                                link: _editedItem.link,
                                logo: value!,
                                id: _editedItem.id,
                                categoryId: _editedItem.categoryId,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
