import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sareesonline/helpers/custom_route.dart';
import 'package:sareesonline/providers/auth.dart';
import 'package:sareesonline/providers/cart.dart';
import 'package:sareesonline/providers/orders.dart';
import 'package:sareesonline/providers/products.dart';
import 'package:sareesonline/screens/auth_screen.dart';
import 'package:sareesonline/screens/cart_screen.dart';
import 'package:sareesonline/screens/edit_product_screen.dart';
import 'package:sareesonline/screens/orders_screen.dart';
import 'package:sareesonline/screens/splash_screen.dart';
import 'package:sareesonline/screens/user_products_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';

//Welcome to my web and android sarees app which use firebase for authentication and storing users and saree's data

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
          create: (_) => Products('', '', []),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
          create: (_) => Orders('', '', []),
        ),
        ChangeNotifierProvider(create: (ctx) => Cart()),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, child) {
        return MaterialApp(
          initialRoute: 'initRoute',
          title: 'The Saree Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          //When the Auth state changes (signed in vs signed out), the Consumer rebuilds the MaterialApp which will reflect either the ProductsOverviewScreen or AuthScreen
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),

          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        );
      }),
    );
  }
}
