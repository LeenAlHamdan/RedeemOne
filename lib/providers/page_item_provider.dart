// ignore_for_file: prefer_final_fields, unnecessary_null_comparison
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '/models/page_item.dart';

class PageItemProvider with ChangeNotifier {
  List<PageItem> _items = [
    /*  PageItem(id: '1', title: 'About', content: ''),
    PageItem(id: '2', title: 'What\'s New', content: ''),
    PageItem(id: '3', title: 'Terms Of Service', content: ''),
    PageItem(id: '4', title: 'Privacy Policy', content: ''),
    PageItem(id: '5', title: 'Contact Us', content: ''), */
  ];

  List<PageItem> get items {
    return [..._items];
  }

  PageItem findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetPageItems() async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/pageitems.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<PageItem> loadedData = [];
      extractedData.forEach((itemId, item) {
        loadedData.add(PageItem(
          id: itemId,
          link: item['link'],
          image: item['image'],
          title: item['title'],
          content: item['content'],
        ));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addItem(PageItem item) async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/pageitems.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': item.title,
            'content': item.content,
            'link': item.link ?? '',
            'image': item.image ?? '',
          }));

      final newItem = PageItem(
          id: json.decode(response.body)['name'],
          title: item.title,
          content: item.content,
          link: item.link,
          image: item.image);
      _items.add(newItem);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateItem(String id, PageItem newItem) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == id);
      final url = Uri.parse(
          'https://redeemone-b36f9-default-rtdb.firebaseio.com/pageitems/$id.json');
      final response = await http.patch(url,
          body: json.encode({
            'title': newItem.title,
            'content': newItem.content,
            'link': newItem.link ?? '',
            'image': newItem.image ?? '',
          }));
      if (response.statusCode >= 400) {
        throw Exception();
      } else {
        _items[itemIndex] = newItem;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
