import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';

class WalletWithBalance {
  wallet mWallet;
  num income;
  num balance;
  double balancePercent;

  WalletWithBalance({this.mWallet, this.balance, this.income});
}