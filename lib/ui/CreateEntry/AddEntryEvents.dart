import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';

class AddEntryEvent {}

class SaveEvent extends AddEntryEvent {
  String amountString;
  String date;
  category selectedCategory;
  wallet selectedWallet;
  tag selectedTag;
  String description;
  bool isIncome;
  int entryId;

  SaveEvent(
      {this.amountString,
        this.date,
        this.selectedCategory,
        this.selectedWallet,
        this.selectedTag,
        this.description,
        this.isIncome,
        this.entryId});
}

class EntryAddedEvent extends AddEntryEvent {}

class CheckFormulaEvent extends AddEntryEvent {
  String formula;
  CheckFormulaEvent({this.formula});
}

class GetCategoriesEvent extends AddEntryEvent {
  bool isIncome;
  GetCategoriesEvent(this.isIncome);
}

class GetWalletsEvent extends AddEntryEvent {}

class CreateCategoryEvent extends AddEntryEvent {
  CreateCategoryEvent(this.name, this.color, this.isIncome);
  String name;
  int color;
  bool isIncome;
}

class GetTagsEvent extends AddEntryEvent {
  GetTagsEvent(this.categoryId);
  int categoryId;
}

class CreateTagEvent extends AddEntryEvent {
  CreateTagEvent(this.name, this.color, this.categoryId);
  String name;
  int color;
  int categoryId;
}

class DeleteCategoryEvent extends AddEntryEvent {
  category mCategory;

  DeleteCategoryEvent(this.mCategory);
}

class DeleteTagEvent extends AddEntryEvent {
  tag mTag;

  DeleteTagEvent(this.mTag);
}

