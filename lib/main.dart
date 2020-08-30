import 'package:flutter/material.dart';
import 'package:piggy_bank/models/breakdowns.dart';
import 'package:piggy_bank/pages/home_page.dart';
import 'package:piggy_bank/theme/theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Breakdowns>(create: (_) => Breakdowns())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Piggy Bank',
        theme: appThemeDark,
        home: HomePage(),
      ),
    );
  }
}
