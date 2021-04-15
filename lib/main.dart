import 'package:inpensefinal_app/data/Sources/App_Preference.dart';
import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/ui/Router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    InpensesApp(),
  );
}

class InpensesApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Provider<LocalDatabase>(
      create: (context) => LocalDatabase(),
      child: MaterialApp(
        title: 'Inpenses',
        theme: ThemeData.light(),
        onGenerateRoute: Routers.generateRoute,
        initialRoute: SplashRoute,
      ),
      dispose: (context, db) => db.close(),
    );
  }
}