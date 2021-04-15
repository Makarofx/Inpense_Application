import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';

class AccountBookWithBalance {
  account_book book;
  double income;
  double expense;

  AccountBookWithBalance(this.book, this.income, this.expense);
}