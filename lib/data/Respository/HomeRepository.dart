import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/CashFlowOfDay.dart';
import 'package:inpensefinal_app/data/Model/CategoryWithTag.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Model/ExpenseOfCategory.dart';
import 'package:inpensefinal_app/data/Model/WalletWithBalance.dart';

abstract class HomeRepository {
  Future<List<WalletWithBalance>> getWalletsWithBalance();
  Future<List<CashFlowOfDay>> getCashFlow(int startTime, int endTime);
  Future<List<ExpenseOfCategory>> getTotalExpenseForAllCategories(
      int startTime, int endTime);
  Future<List<EntryWithCategoryAndWallet>> getTopFiveEntries(
      int startTime, int endTime);
  Future<account_book> getCurrentAccountBook();
  Future<int> clearCurrentAccountBook();
  Future<int> adjustWalletBalance(double amount, int date, int walletId);
  Future<int> createWallet(String name, int color);
  Future<List<EntryWithCategoryAndWallet>> getEntriesBetweenADateRange(
      int startTime, int endTime,
      {List<int> walletIds, List<int> categoryIds, List<int> tagIds});
  Future<int> deleteEntry(entry mEntry);
  Future<List<CategoryWithTag>> getCategoriesWithTags();
  Future<List<wallet>> getWallets();
}
