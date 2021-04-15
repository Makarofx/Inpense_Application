import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/accountbook_with_balance.dart';

abstract class AccountBookStates {
  const AccountBookStates();
}

class AccountBookLoadedState extends AccountBookStates {
  List<AccountBookWithBalance> accountBooks = [];
}

class ViewBookState extends AccountBookStates {}

class ExportEntriesState extends AccountBookStates {

  List<List<dynamic>> row;
  String bookName;

  ExportEntriesState(this.row, this.bookName);
}