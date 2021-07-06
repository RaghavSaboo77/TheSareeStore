import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sareesonline/providers/products.dart';
import 'package:sareesonline/screens/edit_product_screen.dart';
import 'package:sareesonline/widgets/app_drawer.dart';
import 'package:sareesonline/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(false);

    //If Thers is only 1 seller so he is supposed to be the only one editing the products
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<Products>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productData, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: <Widget>[
                                UserProductItem(
                                  productData.items[index].id,
                                  productData.items[index].title,
                                  productData.items[index].imageUrl,
                                ),
                                Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
      drawer: AppDrawer(),
    );
  }
}
