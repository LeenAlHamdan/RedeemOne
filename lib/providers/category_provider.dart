// ignore_for_file: prefer_final_fields, unnecessary_null_comparison
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:redeem_one/models/category.dart';
import 'package:redeem_one/models/http_exception.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [
    /*  Category(
      id: '1',
      title: 'Top Sites',
    ),
    Category(id: '2', title: 'Fashoin'),
    Category(id: '3', title: 'Electroincs'),
    Category(id: '4', title: 'Food & Grocery'),
    Category(id: '5', title: 'Beauty & Wellness'),
    Category(id: '6', title: 'Movie Booking'), */
  ];

  List<Category> get categories {
    return [..._categories];
  }

  Category findById(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  Future<void> fetchAndSetCategories() async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/categories.json');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      final List<Category> loadedData = [];
      extractedData.forEach((itemId, item) {
        loadedData.add(Category(
          id: itemId,
          title: item['title'],
          //    key: GlobalKey<RefreshIndicatorState>()
          //GlobalObjectKey(itemId),
        ));
      });
      _categories = loadedData;

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<String> addCategory(Category category) async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/categories.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': category.title,
        }),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }
      final newCategory = Category(
        id: json.decode(response.body)['name'],
        title: category.title,
        //   key: GlobalKey<RefreshIndicatorState>()
        // GlobalObjectKey(json.decode(response.body)['name']),
      );
      _categories.add(newCategory);
      notifyListeners();
      return newCategory.id;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCategory(String id, Category newCategory) async {
    try {
      final categoryIndex =
          _categories.indexWhere((category) => category.id == id);

      final url = Uri.parse(
          'https://redeemone-b36f9-default-rtdb.firebaseio.com/categories/$id.json');
      final response = await http.patch(url,
          body: json.encode({
            'title': newCategory.title,
          }));
      if (response.statusCode >= 400) {
        throw Exception();
      } else {
        _categories[categoryIndex] = newCategory;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }
}
