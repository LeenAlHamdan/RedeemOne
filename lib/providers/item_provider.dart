import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:redeem_one/models/http_exception.dart';
import 'package:redeem_one/models/iteme.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [
    /*    Item(
        id: '1',
        categoryId: '1',
        title: 'Amazon',
        logo:
            'https://i.pinimg.com/originals/01/ca/da/01cada77a0a7d326d85b7969fe26a728.jpg',
        link: 'https://www.amazon.com/'),
    Item(
        id: '2',
        categoryId: '1',
        title: 'FlipKart',
        logo:
            'https://is3-ssl.mzstatic.com/image/thumb/Purple115/v4/71/1b/40/711b402e-a634-1f30-472e-89560064d095/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png',
        link: 'https://www.flipkart.com/'),
    Item(
        id: '3',
        categoryId: '1',
        title: 'AliExpress',
        logo:
            'https://1000logos.net/wp-content/uploads/2021/04/AliExpress-logo.png',
        link: 'https://www.AliExpress.com/'), 
    Item(
        id: '4',
        categoryId: '2',
        title: 'myntra',
        logo:
            'https://i2.wp.com/img.aapks.com/imgs/0/4/3/043fcc4e2ce11a165ab0d7f9124b9d4e_icon.png',
        link: 'https://www.myntra.com/'),
    Item(
        id: '5',
        categoryId: '2',
        title: 'Ajio',
        logo:
            'https://play-lh.googleusercontent.com/RWNQyHoMPJ-Z8ApQhQchXsfoBXrj3By1cf49GPRK6-hYiIv0RL6Z1fdZl1OAUpqHCB8',
        link: 'https://www.ajio.com/'),
    Item(
        id: '6',
        categoryId: '2',
        title: 'LimeRoad',
        logo:
            'https://images-na.ssl-images-amazon.com/images/I/413RQhldcQL.png',
        link: 'https://www.limeroad.com/'),
    Item(
        id: '7',
        categoryId: '3',
        title: 'Cashify',
        logo:
            'https://res.cloudinary.com/crunchbase-production/image/upload/c_lpad,f_auto,q_auto:eco,dpr_1/smx7sdynbcjrqyp2uyit',
        link: 'https://www.cashify.in/'),
    Item(
        id: '8',
        categoryId: '3',
        title: 'GoNoise',
        logo:
            'https://res.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_256,w_256,f_auto,q_auto:eco,dpr_1/bwvot0kwoyievcgmpdpy',
        link: 'https://www.gonoise.com/'),
    Item(
        id: '9',
        categoryId: '4',
        title: 'Swiggy',
        logo:
            'https://1000logos.net/wp-content/uploads/2021/05/Swiggy-emblem.png',
        link: 'https://www.swiggy.com/'),
    Item(
        id: '10',
        categoryId: '4',
        title: 'FreshMenu',
        logo:
            'https://static.wikia.nocookie.net/logopedia/images/e/e0/FreshMenu.png/revision/latest?cb=20200418071922',
        link: 'https://www.freshmenu.com/'),
    Item(
        id: '11',
        categoryId: '5',
        title: 'BlueStone',
        logo:
            'https://lh3.googleusercontent.com/owySJsCZQ2CtYj54qmymOnfr5dJSd5je63yIINg0x1bB5mARzKDZltxzI7tloV7o7A3x=s85',
        link: 'https://www.bluestone.com/'),
   Item(
        id: '12',
        categoryId: '6',
        title: 'BookMyShow',
        logo:
            'https://pbs.twimg. com/profile_images/1084718695836987392/pT8dY4C-_400x400.jpg',
        link: 'https://in.bookmyshow.com/'),*/
  ];

  final String userId;

  ItemProvider(this.userId, this._items);

  List<Item> get items {
    return [..._items];
  }

  Item findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetItems() async {
    var url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/items.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      final List<Item> loadedData = [];
      extractedData.forEach((itemId, item) {
        loadedData.add(Item(
          id: itemId,
          title: item['title'],
          link: item['link'],
          logo: item['logo'],
          categoryId: item['categoryId'],
        ));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getTodayClicks() async {
    final date2 = DateTime.now().toIso8601String();
    final date1 = DateTime.now()
        .subtract(Duration(
            hours: DateTime.now().hour, minutes: DateTime.now().minute))
        .add(const Duration(minutes: 1))
        .toIso8601String();
    try {
      for (var item in _items) {
        final url = Uri.parse(
            'https://eszi22lp83.execute-api.us-east-2.amazonaws.com/dev/user/public/click?userId=$userId&itemId=${item.id}&fromDate=$date1&toDate=$date2');
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        });

        if (response.statusCode == 201) {
          final clicksData = json.decode(response.body);
          item.clicks = clicksData['count'];

          notifyListeners();
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addItem(Item item) async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/items.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'categoryId': item.categoryId,
            'title': item.title,
            'link': item.link,
            'logo': item.logo,
          }));
      final newItem = Item(
        id: json.decode(response.body)['name'],
        categoryId: item.categoryId,
        title: item.title,
        logo: item.logo,
        link: item.link,
      );
      _items.add(newItem);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateItem(String id, Item newItem) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == id);
      final url = Uri.parse(
          'https://redeemone-b36f9-default-rtdb.firebaseio.com/items/$id.json');
      final response = await http.patch(url,
          body: json.encode({
            'categoryId': newItem.categoryId,
            'title': newItem.title,
            'link': newItem.link,
            'logo': newItem.logo,
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

  Future<void> clicksItemCount(DateTime dateTime1, DateTime dateTime2) async {
    var date1 = dateTime1.toIso8601String();
    var date2 = dateTime2.toIso8601String();
    try {
      for (var item in _items) {
        final url = Uri.parse(
            'https://eszi22lp83.execute-api.us-east-2.amazonaws.com/dev/user/public/click?userId=$userId&itemId=${item.id}&fromDate=$date1&toDate=$date2');
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        });

        if (response.statusCode == 201) {
          final clicksData = json.decode(response.body);
          item.clicks = clicksData['count'];

          notifyListeners();
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> clicksItem(String itemId) async {
    final today = DateTime.now().millisecondsSinceEpoch;

    final url = Uri.parse(
        'https://eszi22lp83.execute-api.us-east-2.amazonaws.com/dev/user/public/clicks');

    try {
      final response = await http.post(url,
          body: json.encode({
            'userId': userId,
            'itemId': itemId,
            'date': today,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          });

      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }
    } catch (error) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/items/$id.json');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingItem = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingItem);
      notifyListeners();
      throw HttpException('Could not delete Item.');
    }
  }

  /*  Future<void> clicksItem(String itemId) async {
    final item = findById(itemId);
    final today = (DateFormat('yyyy-MM-dd')).format(DateTime.now());
    var url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/userClicks/$userId/$today/$itemId.json?auth=$authToken');
    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }
      final clicksData = json.decode(response.body);

      final oldVal = clicksData == null ? 0 : clicksData ?? 0;
      item.clicks = oldVal;
      item.clicks += 1;
      notifyListeners();
      url = Uri.parse(
          'https://redeemone-b36f9-default-rtdb.firebaseio.com/userClicks/$userId/$today/$itemId.json?auth=$authToken');
      final putResponse = await http.put(
        url,
        body: json.encode(
          item.clicks,
        ),
      );
      if (putResponse.statusCode >= 400) {
        item.clicks = oldVal;
        notifyListeners();
        throw HttpException('Error heppend!');
      }
    } catch (error) {
      rethrow;
    }
  } */
}
