import 'package:inpensefinal_app/ui/AccountBook/AccountBookView.dart';
import 'package:inpensefinal_app/ui/CreateEntry/CreateEntry.dart';
import 'package:inpensefinal_app/ui/EditEntry/EditEntryView.dart';
import 'package:inpensefinal_app/ui/Home/HomeView.dart';
import 'package:inpensefinal_app/ui/Splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'Entries/entries_view.dart';

const String SplashRoute = "/";
const String AccountBookRoute = "account_book";
const String HomeRoute = "home";
const String CreateEntryRout = "create_entry";
const String EntriesRoute = "entries";
const String EditEntry = "edit_entry";

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashRoute:
        return MaterialPageRoute(builder: (_) => SplashView());
      case AccountBookRoute:
        return MaterialPageRoute(builder: (_) => AccountBookScreen());
      case HomeRoute:
        return MaterialPageRoute(builder: (_) => HomeView());
      case CreateEntryRout:
        return MaterialPageRoute(builder: (_) => CreateEntryPage());
      case EntriesRoute:
        return MaterialPageRoute(
            builder: (_) => EntriesView(), settings: settings);
      case EditEntry:
        return MaterialPageRoute(
            builder: (_) => EditEntryView(), settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}
