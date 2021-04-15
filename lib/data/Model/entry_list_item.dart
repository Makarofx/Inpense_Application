import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';

class EntryListItem {
  int type;
  String date;
  EntryWithCategoryAndWallet item;

  EntryListItem(this.type, {this.date, this.item});
}