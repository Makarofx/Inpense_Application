import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Model/accountbook_with_balance.dart';

abstract class AccountBookRepository {

  Future<List<AccountBookWithBalance>> getAllAccountBooks();
  Stream<int> createAnAccountBook(account_book book);
  Future<int> editAnAccountBook(account_book book);
  Future<int> saveCurrentAccountBook(account_book book);
  Future<void> deleteAnAccountBook(account_book book);
  Future<account_book> getCurrentBook();
  Future<List<EntryWithCategoryAndWallet>> getAllEntries(int bookId);

}