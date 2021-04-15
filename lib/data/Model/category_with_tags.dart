import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';

class CategoryWithTags {
  category mCategory;
  List<tag> tags;

  CategoryWithTags(this.mCategory, this.tags);

  List<int> checkedTagIndexes = [];
}