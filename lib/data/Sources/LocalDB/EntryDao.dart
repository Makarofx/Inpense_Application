import 'package:moor_flutter/moor_flutter.dart';
import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/CashFlowOfDay.dart';
import 'package:inpensefinal_app/data/Model/Category.dart';
import 'package:inpensefinal_app/data/Model/Entry.dart';
import 'package:inpensefinal_app/data/Model/ExpenseOfCategory.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Model/Tag.dart';
import 'package:inpensefinal_app/data/Model/Wallet.dart';

part 'EntryDao.g.dart';

@UseDao(tables: [Entry, Tag, Category, Wallet])
class EntryDao extends DatabaseAccessor<LocalDatabase> with _$EntryDaoMixin {
  LocalDatabase _database;

  EntryDao(LocalDatabase database) : super(database) {
    this._database = database;
  }

  Future<List<EntryWithCategoryAndWallet>> getTopFiveEntry(
      int startTimeInMillis, int endTimeInMillis, int bookId) {
    final query = select(_database.entry).join([
      leftOuterJoin(_database.wallet,
          _database.entry.walletId.equalsExp(_database.wallet.id)),
      leftOuterJoin(_database.category,
          _database.category.id.equalsExp(_database.entry.categoryId)),
      leftOuterJoin(
          _database.tag, _database.tag.id.equalsExp(_database.entry.tagId))
    ])
      ..where(_database.entry.bookId.equals(bookId) &
      _database.entry.date
          .isBetweenValues(startTimeInMillis, endTimeInMillis))
      ..orderBy([OrderingTerm.desc(_database.entry.amount.abs())])
      ..limit(5);

    return query.map((row) {
      return EntryWithCategoryAndWallet(
          row.readTable(_database.entry),
          row.readTable(_database.category),
          row.readTable(_database.tag),
          row.readTable(_database.wallet));
    }).get();
  }

  Future<List<EntryWithCategoryAndWallet>> getEntriesBetweenADateRange(
      int startTimeInMillis, int endTimeInMillis, int bookId,
      {List<int> walletIds, List<int> categoryIds, List<int> tagIds}) {
    Expression<bool> expression = _database.entry.bookId.equals(bookId) &
    _database.entry.date
        .isBetweenValues(startTimeInMillis, endTimeInMillis);
    if (walletIds != null && walletIds.length > 0) {
      expression = expression & _database.entry.walletId.isIn(walletIds);
    }
    if (categoryIds != null && categoryIds.length > 0) {
      expression = expression & _database.entry.categoryId.isIn(categoryIds);
    }
    if (tagIds != null && tagIds.length > 0) {
      expression = expression & _database.entry.tagId.isIn(tagIds);
    }

    final query = select(_database.entry).join([
      leftOuterJoin(_database.wallet,
          _database.entry.walletId.equalsExp(_database.wallet.id)),
      leftOuterJoin(_database.category,
          _database.category.id.equalsExp(_database.entry.categoryId)),
      leftOuterJoin(
          _database.tag, _database.tag.id.equalsExp(_database.entry.tagId))
    ])
      ..where(expression)
      ..orderBy([OrderingTerm.asc(_database.entry.date)]);

    return query.map((row) {
      return EntryWithCategoryAndWallet(
          row.readTable(this.entry),
          row.readTable(this.category),
          row.readTable(this.tag),
          row.readTable(this.wallet));
    }).get();
  }

  Future<List<EntryWithCategoryAndWallet>> getAllEntries(int bookId) {
    final query = select(_database.entry).join([
      leftOuterJoin(_database.wallet,
          _database.entry.walletId.equalsExp(_database.wallet.id)),
      leftOuterJoin(_database.category,
          _database.category.id.equalsExp(_database.entry.categoryId)),
      leftOuterJoin(
          _database.tag, _database.tag.id.equalsExp(_database.entry.tagId))
    ])
      ..where(_database.entry.bookId.equals(bookId))
      ..orderBy([OrderingTerm.desc(_database.entry.amount)]);

    return query.map((row) {
      return EntryWithCategoryAndWallet(
          row.readTable(this.entry as TableInfo<$EntryTable, entry>),
          row.readTable(this.category as TableInfo<$CategoryTable, category>),
          row.readTable(this.tag as TableInfo<$TagTable, tag>),
          row.readTable(this.wallet as TableInfo<$WalletTable, wallet>));
    }).get();
  }

  Future<int> insertEntry(entry entry) {
    return into(_database.entry).insert(entry);
  }

  Future<bool> updateEntry(entry entry) {
    return update(_database.entry).replace(entry);
  }

  Future<int> deleteEntry(entry entry) {
    return delete(_database.entry).delete(entry);
  }

  Stream<int> updateAllEntriesCategory(
      int categoryIdToBeReplaced, int categoryIdToReplace) {
    return (update(_database.entry)
      ..where((tbl) => tbl.categoryId.equals(categoryIdToBeReplaced)))
        .write(EntryCompanion(categoryId: Value(categoryIdToBeReplaced)))
        .asStream();
  }

  Stream<int> removeAllEntriesTag(int tagIdToBeRemoved) {
    return (update(_database.entry)
      ..where((tbl) => tbl.tagId.equals(tagIdToBeRemoved)))
        .write(EntryCompanion(categoryId: Value(null)))
        .asStream();
  }

  Future<List<ExpenseOfCategory>> getTotalExpenseForAllCategories(
      int startTime, int endTime, int bookId) {
    final total = _database.entry.amount.sum();
    final name = _database.category.name;
    final color = _database.category.color;

    final query = select(_database.entry).join([
      leftOuterJoin(_database.wallet,
          _database.entry.walletId.equalsExp(_database.wallet.id)),
      leftOuterJoin(_database.category,
          _database.category.id.equalsExp(_database.entry.categoryId)),
      leftOuterJoin(
          _database.tag, _database.tag.id.equalsExp(_database.entry.tagId))
    ])
      ..addColumns([total, name, color])
      ..where(_database.entry.bookId.equals(bookId) &
      _database.entry.date.isBetweenValues(startTime, endTime) &
      _database.category.isIncome.equals(false))
      ..orderBy([OrderingTerm.desc(_database.entry.amount)]);

    return query.map((event) {
      return ExpenseOfCategory(
          event.read(total), event.read(name), event.read(color));
    }).get();
  }

  Future<List<CashFlowOfDay>> getCashFlow(
      int startDate, int endDate, int bookId) {
    final income = CustomExpression<double>(
        "SUM(CASE WHEN entry.amount>=0 THEN entry.amount ELSE 0 END)");
    final expense = CustomExpression<double>(
        "SUM(CASE WHEN entry.amount<=0 THEN entry.amount ELSE 0 END)");
    final date = _database.entry.date;

    final query = select(_database.entry).join([
      leftOuterJoin(_database.wallet,
          _database.entry.walletId.equalsExp(_database.wallet.id)),
      leftOuterJoin(_database.category,
          _database.category.id.equalsExp(_database.entry.categoryId)),
      leftOuterJoin(
          _database.tag, _database.tag.id.equalsExp(_database.entry.tagId))
    ])
      ..addColumns([income, expense, date])
      ..where(_database.entry.bookId.equals(bookId) &
      _database.entry.date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(_database.entry.amount)]);

    return query.map((event) {
      return CashFlowOfDay(
          event.read(income), event.read(expense), event.read(date));
    }).get();
  }

  Stream<int> updateAllEntriesWallet(int walletId) {
    return (update(_database.entry)..where((tbl) => tbl.categoryId.equals(1)))
        .write(EntryCompanion(categoryId: Value(walletId)))
        .asStream();
  }
}
