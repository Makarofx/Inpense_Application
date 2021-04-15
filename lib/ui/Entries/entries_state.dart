import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Model/category_with_tags.dart';
import 'package:inpensefinal_app/data/Model/entry_list_item.dart';

class EntriesState {}

class GetEntriesState extends EntriesState {
  List<EntryListItem> entries;
  List<EntryWithCategoryAndWallet> rawEntries;

  GetEntriesState(this.entries, this.rawEntries);
}

class GetWalletsAndCategoriesState extends EntriesState {
  List<wallet> wallets;
  List<CategoryWithTags> categories;

  GetWalletsAndCategoriesState(this.wallets, this.categories);
}