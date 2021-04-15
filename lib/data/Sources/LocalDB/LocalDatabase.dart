import 'package:inpensefinal_app/data/Sources/LocalDB/AccountBookDao.dart';
import 'package:inpensefinal_app/data/Sources/LocalDB/CategoryDao.dart';
import 'package:inpensefinal_app/data/Sources/LocalDB/EntryDao.dart';
import 'package:inpensefinal_app/data/Sources/LocalDB/WalletDao.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:inpensefinal_app/data/Model/AccountBook.dart';
import 'package:inpensefinal_app/data/Model/Category.dart';
import 'package:inpensefinal_app/data/Model/Entry.dart';
import 'package:inpensefinal_app/data/Model/Tag.dart';
import 'package:inpensefinal_app/data/Model/Wallet.dart';

part 'LocalDatabase.g.dart';

@UseMoor(
  tables: [AccountBook, Category, Entry, Tag, Wallet],
  daos: [AccountBookDao, CategoryDao,EntryDao, WalletDao]
)

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(): super(FlutterQueryExecutor.inDatabaseFolder(path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;
}
