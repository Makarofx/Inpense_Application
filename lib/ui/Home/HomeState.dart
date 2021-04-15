import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Model/ExpenseOfCategory.dart';
import 'package:inpensefinal_app/data/Model/WalletWithBalance.dart';

class HomeState {}

class InitState extends HomeState {}

class LoadingState extends HomeState {}

class WalletsState extends HomeState {
  List<WalletWithBalance> wallets;

  WalletsState(this.wallets);

}

class CashFlowState extends HomeState {
  double income;
  double expense;
  List<double> data = [];

  CashFlowState(this.income, this.expense) {
    data..add(income)..add(expense);
  }
}

class ExpenseOfCategoryState extends HomeState {
  List<ExpenseOfCategory> expenses;

  ExpenseOfCategoryState(this.expenses);
}

class TopFiveEntriesState extends HomeState {
  List<EntryWithCategoryAndWallet> entries = [];

  TopFiveEntriesState({this.entries});
}

class GetAccountBookState extends HomeState {
  account_book book;

  GetAccountBookState(this.book);
}

class ClearAccountBookState extends HomeState {}

class ResetState extends HomeState {}