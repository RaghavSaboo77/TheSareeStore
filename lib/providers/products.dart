import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sareesonline/models/http_exception.dart';
import 'dart:convert';
import 'package:sareesonline/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  //var _showFavoritesOnly = false;

  //Provides a COPY of the _items and not a direct reference to the _items, so that it cannot be accessed and modified outside the class.
  //If items are to be added, other classes must go through the addProduct() method so that it can notifyListeners(), and other listeners get updated info
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-update-9f403.firebaseio.com/products.json?auth=$authToken&$filterString';
    // print(url);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final favoriteUrl =
          'https://flutter-update-9f403.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      print("hello");
      print("5" + favoriteUrl);

      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData2) {
          var prodData = HashMap.from(prodData2);
          print(prodId.runtimeType);
          print(prodData.runtimeType);
          print(prodData['title']);
          print(prodId + prodData['imageUrl'] + "Comeon");
          loadedProducts.add(
            Product(
                id: prodId,
                title: prodData['title'],
                description: prodData['description'],
                price: prodData['price'],
                imageUrl: prodData['imageUrl'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData[prodId] ?? false),
          );

          print("I am IN");
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    //Can't just pass the whole product in since we need to provide an ID. And you can't just reassign the ID since it's final.
    final url =
        'https://flutter-update-9f403.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        //Realtime database response looks like {name: -uniquekey}
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      //throwing a new error so it can be handled elsewhere
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-update-9f403.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-9f403.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    //grab a copy of the item to be deleted and store it in memory
    var existingProduct = _items[existingProductIndex];
    //optimistically updates the local memory
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    //if this executes then the action succeed, and lets Dart clear the copy from memory
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    } else {
      existingProduct = null;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}
