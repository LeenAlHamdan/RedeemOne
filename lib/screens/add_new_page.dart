import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/page_item.dart';
import 'package:redeem_one/providers/page_item_provider.dart';

class AddNewPage extends StatefulWidget {
  static const routeName = '/addPage';

  @override
  State<AddNewPage> createState() => _AddNewPageState();
}

class _AddNewPageState extends State<AddNewPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _linkController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageUrlController;
  final _imageUrlFocusNode = FocusNode();

  final _linkFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  PageItem? _editedPage;

  bool _isLoading = false;
  bool _hasLink = false;
  bool _hasImage = false;
  bool _isInit = true;
  bool _isEdit = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _contentController.dispose();
    _titleController.dispose();
    _imageUrlController.dispose();
    _linkController.dispose();

    _imageUrlFocusNode.dispose();
    _linkFocusNode.dispose();
    _contentController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final data =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (data != null) {
        _editedPage = data['page'] as PageItem;
        _titleController = TextEditingController(text: _editedPage!.title);
        _hasLink = _editedPage!.link != null && _editedPage!.link != '';
        _linkController = TextEditingController(text: _editedPage!.link ?? '');
        _imageUrlController =
            TextEditingController(text: _editedPage!.image ?? '');
        _contentController = TextEditingController(text: _editedPage!.content);

        _isEdit = true;
      } else {
        _isEdit = false;
        _titleController = TextEditingController();
        _linkController = TextEditingController();
        _contentController = TextEditingController();
        _imageUrlController = TextEditingController();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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

  Future<void> add(BuildContext context) async {
    try {
      await Provider.of<PageItemProvider>(context, listen: false).addItem(
        PageItem(
            id: '0',
            image: _imageUrlController.text,
            link: _linkController.text,
            title: _titleController.text,
            content: _contentController.text),
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> update(BuildContext context) async {
    try {
      await Provider.of<PageItemProvider>(context, listen: false).updateItem(
        _editedPage!.id,
        PageItem(
            id: _editedPage!.id,
            title: _titleController.text,
            image: _imageUrlController.text != null &&
                    _imageUrlController.text != ''
                ? _imageUrlController.text
                : '',
            link: _linkController.text != null && _linkController.text != ''
                ? _linkController.text
                : '',
            content: _contentController.text),
      );
    } catch (error) {
      throw error;
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Add Image'),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _hasImage = true;
                      });
                      FocusScope.of(context).requestFocus(_imageUrlFocusNode);
                    }),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Add hyperlink'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _hasLink = true;
                    });
                    FocusScope.of(context).requestFocus(_linkFocusNode);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isEdit) {
        await update(context);
      } else {
        await add(context);
      }
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit ${_editedPage!.title}' : 'Add Page'),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                child: Center(
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
                ),
              )
            : Form(
                key: _form,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                        labelText: 'title',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      controller: _titleController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_contentFocusNode);
                      },
                      autofocus: true,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: MediaQuery.of(context).size.height - 300,
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextFormField(
                                  minLines: 5,
                                  maxLines: 1000,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Theme.of(context).primaryColor,
                                  decoration: InputDecoration(
                                    labelText: 'Content',
                                    alignLabelWithHint: true,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  controller: _contentController,
                                  keyboardType: TextInputType.multiline,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    }
                                    return null;
                                  },
                                  focusNode: _contentFocusNode,
                                  onFieldSubmitted: (_) {
                                    if (_hasLink) {
                                      FocusScope.of(context)
                                          .requestFocus(_linkFocusNode);
                                    } else if (_hasImage) {
                                      FocusScope.of(context)
                                          .requestFocus(_imageUrlFocusNode);
                                    }
                                  },
                                  autofocus: true,
                                ),
                                Visibility(
                                  visible: _hasLink,
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    cursorColor:
                                        Theme.of(context).primaryColorDark,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                      ),
                                      labelText: 'hyperlink',
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    controller: _linkController,
                                    onFieldSubmitted: (_) {
                                      if (_hasImage) {
                                        FocusScope.of(context)
                                            .requestFocus(_imageUrlFocusNode);
                                      }
                                    },
                                    focusNode: _linkFocusNode,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please provide a value.';
                                      }
                                      if (!value.startsWith('http') &&
                                          !value.startsWith('https')) {
                                        return 'Please enter a valid URL.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(_linkFocusNode);
                                    },
                                  ),
                                ),
                                _hasImage
                                    ? Visibility(
                                        visible: _hasImage,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                              child: _imageUrlController
                                                      .text.isEmpty
                                                  ? const Center(
                                                      child: Text(
                                                        'Enter a URL',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : FittedBox(
                                                      child: Image.network(
                                                        _imageUrlController
                                                            .text,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                cursorColor: Theme.of(context)
                                                    .primaryColorDark,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 3),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        width: 3),
                                                  ),
                                                  labelText: 'Image URL',
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                keyboardType: TextInputType.url,
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller: _imageUrlController,
                                                focusNode: _imageUrlFocusNode,
                                                onFieldSubmitted: (_) {
                                                  _updateImageUrl();
                                                },
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter an image URL.';
                                                  }
                                                  if (!value
                                                          .startsWith('http') &&
                                                      !value.startsWith(
                                                          'https')) {
                                                    return 'Please enter a valid URL.';
                                                  }
                                                  if (!value.endsWith('.png') &&
                                                      !value.endsWith('.jpg') &&
                                                      !value
                                                          .endsWith('.jpeg')) {
                                                    return 'Please enter a valid image URL.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : (_isEdit &&
                                            (_editedPage!.image != null &&
                                                _editedPage!.image != ''))
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _hasImage = true;
                                              });
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      _imageUrlFocusNode);
                                            },
                                            child: Image.network(
                                              _editedPage!.image!,
                                              fit: BoxFit.cover,
                                              height: 150,
                                              width: double.infinity,
                                            ),
                                          )
                                        : Container(),
                              ],
                            ),
                          ),
                          Positioned(
                              top: 0,
                              right: 5,
                              child: IconButton(
                                onPressed: () => _showPicker(context),
                                icon: const Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel_rounded,
                            size: 35,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _saveForm(),
                          icon: Icon(
                            Icons.check_circle,
                            size: 35,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
      ),
    );
  }
}
