import 'package:inpensefinal_app/data/Respository/HomeRepositoryImpl.dart';
import 'package:inpensefinal_app/ui/Router.dart';
import 'package:inpensefinal_app/ui/Home/CashFlowView.dart';
import 'package:inpensefinal_app/ui/Home/CreateWalletDialog.dart';
import 'package:inpensefinal_app/ui/Home/HomeBloc.dart';
import 'package:inpensefinal_app/ui/Home/HomeEvent.dart';
import 'package:inpensefinal_app/ui/Home/HomeState.dart';
import 'package:inpensefinal_app/ui/Home/WalletItemView.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  HomeBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc = HomeBloc(HomeRepositoryImpl(context));
    return BlocProvider(
      create: (context) => _bloc,
      child: Builder(
        builder: (contextB) {
          _bloc.add(GetAccountBookEvent());
          return BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is ClearAccountBookState) {
                Navigator.pushReplacementNamed(context, AccountBookRoute);
              }
            },
            listenWhen: (context, state) => state is HomeState,
            buildWhen: (context, state) => state is GetAccountBookState,
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Color(0xFFE5EAEC),
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  title: Text(
                    state == null
                        ? "Home"
                        : (state as GetAccountBookState).book.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    MaterialButton(
                      child: Text("change".toUpperCase()),
                      textColor: Colors.white,
                      onPressed: () {
                        _bloc.add(ClearAccountBookEvent());
                      },
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  child: Image.asset(
                    "assets/images/ic_plus.png",
                    width: 24,
                    height: 24,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, CreateEntryRout)
                        .then((value) => _bloc.add(ResumeEvent()));
                  },
                ),
                body: HomeBodyView(),
              );
            },
          );
        },
      ),
    );
  }
}

class HomeBodyView extends StatefulWidget {
  Key walletListKey = new Key(
      Random(DateTime.now().millisecondsSinceEpoch).nextInt(1000).toString());

  HomeBodyView({Key key}) : super(key: key);

  @override
  State createState() {
    return HomeBodyState();
  }
}

class HomeBodyState extends State<HomeBodyView> with WidgetsBindingObserver {
  int _selectedPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      BlocProvider.of<HomeBloc>(context).add(ResumeEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<HomeBloc>(context).add(GetWalletsEvent());
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    "Wallets",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                Container(
                  child: MaterialButton(
                      child: Text(
                        "Create",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        _showAddWalletDialog();
                      }),
                )
              ],
            ),
            Container(
              height: 150,
              margin: EdgeInsets.only(left: 10, top: 10),
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {},
                buildWhen: (context, state) => state is WalletsState,
                builder: (context, state) {
                  print(state);
                  int walletCount = 0;
                  walletCount = !(state is WalletsState)
                      ? 0
                      : (state as WalletsState).wallets.length;
                  print(walletCount);
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: walletCount,
                    itemBuilder: (context, int index) {
                      return Provider(
                        create: (_) => (state as WalletsState).wallets[index],
                        key: ObjectKey(
                            (state as WalletsState).wallets[index].balance),
                        child: WalletItemView(
                          selectedPosition: _selectedPosition,
                          currentPosition: index,
                          callback: (position) {
                            _selectedPosition = position;
                            setState(() {});
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            CashFlowView(),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (contextC) => CreateWalletDialog(
          callback: (name, color, id) {
            print("$name");
            BlocProvider.of<HomeBloc>(context)
              ..add(CreateWalletEvent(name, color));
          },
        ));
  }
}