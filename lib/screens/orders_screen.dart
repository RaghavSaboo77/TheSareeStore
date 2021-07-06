import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sareesonline/providers/orders.dart' show Orders;
import 'package:sareesonline/widgets/app_drawer.dart';
import 'package:sareesonline/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<void> _fetchSetOrders;

  @override
  void initState() {
    super.initState();
    _fetchSetOrders =
        Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: _fetchSetOrders,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              //.. do error handling
              return Center(
                child: Text('An error occured!'),
              );
            } else {
              //Instead of using the Provider.of method above which rebuilds the entire build method when data changes and makes multiple calls to fetch Orders,
              //only rebuild the ListView when data changes (avoiding multiple calls and an infinite loop)
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                return ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, index) {
                    //Individual order widget
                    return OrderItem(orderData.orders[index]);
                  },
                );
              });
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
