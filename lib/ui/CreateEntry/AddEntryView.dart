import 'dart:ui';

import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Model/EntryWithCategoryAndWallet.dart';
import 'package:inpensefinal_app/data/Respository/EntryRepositoryImpl.dart';
import 'package:inpensefinal_app/ui/ChipGroup.dart';
import 'package:inpensefinal_app/ui/CreateEntry/AddEntryBloc.dart';
import 'package:inpensefinal_app/ui/CreateEntry/AddEntryStates.dart';
import 'package:inpensefinal_app/ui/CreateEntry/CalculatorKeyBoardView.dart';
import 'package:inpensefinal_app/ui/CreateEntry/CreateEntryBloc.dart';
import 'package:inpensefinal_app/ui/Home/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:inpensefinal_app/ui/CreateEntry/AddEntryEvents.dart';
import 'package:inpensefinal_app/ui/CreateEntry/CreateCategoryDialog.dart';
import 'package:inpensefinal_app/ui/CreateEntry/CreateTagDialog.dart';

typedef void CategorySelectionCallback(int color);

class AddEntryFormWidget extends StatelessWidget {
  CategorySelectionCallback categorySelectionCallback;
  bool isIncome = false;
  EntryWithCategoryAndWallet entry;

  AddEntryFormWidget(this.categorySelectionCallback, this.isIncome,
      {this.entry});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddEntryBloc(EntryRepositoryImpl(context)),
      child: Builder(builder: (contextB) {
        BlocProvider.of<AddEntryBloc>(contextB)
          ..add(GetCategoriesEvent(isIncome));
        BlocProvider.of<AddEntryBloc>(contextB)..add(GetWalletsEvent());
        return AddEntryStatefulFormWidget(
          categorySelectionCallback,
          isIncome,
          entry: entry,
        );
      }),
    );
  }
}

class AddEntryStatefulFormWidget extends StatefulWidget {
  CategorySelectionCallback categorySelectionCallback;
  bool isIncome = false;
  EntryWithCategoryAndWallet entry;
  final _formKey = GlobalKey<FormState>();
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  CalendarController _calendarController = CalendarController();
  TextEditingController _amountTextController = TextEditingController();
  TextEditingController _dateTextController = TextEditingController();
  TextEditingController _descriptionTextController = TextEditingController();

  AddEntryStatefulFormWidget(this.categorySelectionCallback, this.isIncome,
      {this.entry});

  @override
  State createState() {
    return AddEntryState();
  }
}

class AddEntryState extends State<AddEntryStatefulFormWidget>
    with SingleTickerProviderStateMixin {
  List<category> _categories = [];
  category _selectedCategory;
  wallet _selectedWallet;
  tag _selectedTag;
  Widget view;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      final formatter = DateFormat("dd-MM-yyyy");
      widget._amountTextController.text =
          widget.entry.mEntry.amount.abs().toString();
      widget._dateTextController.text = formatter.format(
          DateTime.fromMillisecondsSinceEpoch(widget.entry.mEntry.date));
      widget._descriptionTextController.text = widget.entry.mEntry.description;
    }
    widget._controller =
        AnimationController(vsync: this, duration: Duration(microseconds: 500));
    widget._offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: widget._controller,
          curve: Curves.ease,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!BlocProvider.of<AddEntryBloc>(context).errorSubject.hasListener) {
      BlocProvider.of<AddEntryBloc>(context).errorSubject.listen((event) {
        final snackBar = SnackBar(
          content: Text(
            event.toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        Scaffold.of(context).showSnackBar(snackBar);
      });
    }
    return Form(
        key: widget._formKey,
        child: BlocListener(
          listener: (context, state) {
            final snackBar = SnackBar(
              content: Text(
                "Entry saved successfully",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            );
            if (state is EntrySavedState) {
              Scaffold.of(context).showSnackBar(snackBar);
              BlocProvider.of<CreateEntryBloc>(context).add(EntryAddedEvent());
              view = null;
              widget._amountTextController.clear();
              widget._descriptionTextController.clear();
              setState(() {});
            }
          },
          bloc: BlocProvider.of<AddEntryBloc>(context),
          child: StreamBuilder(
            stream:
            BlocProvider.of<CreateEntryBloc>(context).saveButtonListener,
            builder: (context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData && snapshot.data == 1) {
                BlocProvider.of<AddEntryBloc>(context).add(SaveEvent(
                    amountString: widget._amountTextController.text.toString(),
                    date: widget._dateTextController.text.toString(),
                    selectedCategory: _selectedCategory,
                    selectedWallet: _selectedWallet,
                    selectedTag: _selectedTag,
                    description:
                    widget._descriptionTextController.text.toString(),
                    isIncome: widget.isIncome,
                    entryId:
                    widget.entry == null ? null : widget.entry.mEntry.id));
              } else if (view == null) {
                view = Stack(
                  children: [
                    NotificationListener(
                      onNotification: (notification) {
                        print(notification);
                        if (notification is ScrollUpdateNotification &&
                            (notification.scrollDelta >= 1.0 ||
                                notification.scrollDelta <= -1.0) &&
                            widget._controller.status ==
                                AnimationStatus.completed) {
                          widget._controller.reverse();
                        }
                        return false;
                      },
                      child: GestureDetector(
                        onTapDown: (_) => widget._controller.reverse(),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 20.0,
                                      right: 0.0,
                                      bottom: 0.0),
                                  child: Text(
                                    "Amount",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      right: 10.0,
                                      bottom: 0.0),
                                  child: StreamBuilder(
                                    stream:
                                    BlocProvider.of<AddEntryBloc>(context)
                                        .amountFormula,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        widget._amountTextController.text =
                                        snapshot.data as String;
                                        widget._amountTextController.selection =
                                            TextSelection.collapsed(
                                                offset: widget
                                                    ._amountTextController
                                                    .text
                                                    .length);
                                      }
                                      return TextFormField(
                                        maxLines: 1,
                                        showCursor: true,
                                        readOnly: true,
                                        controller:
                                        widget._amountTextController,
                                        onTap: () {
                                          widget._controller.forward();
                                        },
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Text is empty';
                                          } else {}
                                          return null;
                                        },
                                        onChanged: (text) {
                                          if (text.length > 1) {
                                            widget._formKey.currentState
                                                .validate();
                                          }
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Enter amount",
                                            errorText: snapshot.error != null
                                                ? snapshot.error
                                                .toString()
                                                .split(':')[1]
                                                : null,
                                            filled: true,
                                            fillColor: Color(0xFFD3DADD),
                                            hintStyle: TextStyle(
                                                color: Color(0xFF263238)),
                                            errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            focusedErrorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            focusedBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(3.0)))),
                                      );
                                    },
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 20.0,
                                      right: 0.0,
                                      bottom: 0.0),
                                  child: Text(
                                    "Date",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      right: 10.0,
                                      bottom: 0.0),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      TextFormField(
                                        maxLines: 1,
                                        showCursor: false,
                                        readOnly: true,
                                        controller: widget._dateTextController,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Text is empty';
                                          }
                                          return null;
                                        },
                                        onChanged: (text) {
                                          if (text.length > 1) {
                                            widget._formKey.currentState
                                                .validate();
                                          }
                                        },
                                        onTap: () {
                                          widget._controller.reverse();
                                          _showDatePicker();
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Select task date",
                                            filled: true,
                                            fillColor: Color(0xFFD3DADD),
                                            hintStyle: TextStyle(
                                                color: Color(0xFF263238)),
                                            errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            focusedErrorBorder:
                                            UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0)))),
                                      ),
                                      Container(
                                        height: 48,
                                        width: 50,
                                        child: RawMaterialButton(
                                          fillColor: Colors.pink,
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                            child: Image.asset(
                                                "assets/images/ic_calendar.png"),
                                          ),
                                          onPressed: () {
                                            widget._controller.reverse();
                                            _showDatePicker();
                                          },
                                        ),
                                      )
                                    ],
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 20.0,
                                      right: 0.0,
                                      bottom: 0.0),
                                  child: Text(
                                    "Category",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      right: 10.0,
                                      bottom: 0.0),
                                  child: StreamBuilder(
                                    stream:
                                    BlocProvider.of<AddEntryBloc>(context)
                                        .categories,
                                    builder: (context,
                                        AsyncSnapshot<List<category>>
                                        snapshot) {
                                      if (snapshot.hasData) {
                                        int selectedCategoryIndex = -1;
                                        if (widget.entry != null) {
                                          selectedCategoryIndex = snapshot.data
                                              .indexWhere((element) =>
                                          element.id ==
                                              widget.entry.mCategory.id);
                                          _selectedCategory =
                                              widget.entry.mCategory;
                                          BlocProvider.of<AddEntryBloc>(context)
                                            ..add(GetTagsEvent(
                                                widget.entry.mCategory.id));
                                        }
                                        return ChipGroup(
                                            snapshot.data
                                                .map((e) => e.name)
                                                .toList(),
                                            chipColors: snapshot.data
                                                .map((e) => e.color)
                                                .toList(),
                                            cancelableIndexes: snapshot.data
                                                .map((e) => e.canDelete)
                                                .toList(),
                                            selectedIndex:
                                            selectedCategoryIndex,
                                            onChipSelectedCallback:
                                                (List<int> index) {
                                              _selectedCategory =
                                              snapshot.data[index[0]];
                                              this
                                                  .widget
                                                  .categorySelectionCallback
                                                  .call(snapshot
                                                  .data[index[0]].color);
                                              BlocProvider.of<AddEntryBloc>(context)
                                                ..add(GetTagsEvent(
                                                    snapshot.data[index[0]].id));
                                            }, onChipCanceled: (int index) {
                                          _showDeleteConfirmationDialog(
                                              DeleteCategoryEvent(
                                                  snapshot.data[index]),
                                              "category");
                                        });
                                      } else {
                                        return ChipGroup([]);
                                      }
                                    },
                                  )),
                              Container(
                                height: 45,
                                margin: EdgeInsets.only(
                                    left: 10.0,
                                    top: 10.0,
                                    right: 10.0,
                                    bottom: 0.0),
                                child: RaisedButton(
                                  color: Colors.white,
                                  disabledColor: Colors.white,
                                  highlightColor: Colors.white70,
                                  splashColor: Colors.blue.withOpacity(0.2),
                                  elevation: 0,
                                  onPressed: () {
                                    _showAddCategoryDialog();
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    side: BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/ic_add.png",
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.centerLeft,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            "add category".toUpperCase(),
                                            style:
                                            TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 20.0,
                                      right: 0.0,
                                      bottom: 0.0),
                                  child: Text(
                                    "Wallet",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      right: 10.0,
                                      bottom: 0.0),
                                  child: StreamBuilder(
                                    stream:
                                    BlocProvider.of<AddEntryBloc>(context)
                                        .wallets,
                                    builder: (context,
                                        AsyncSnapshot<List<wallet>> snapshot) {
                                      if (snapshot.hasData) {
                                        int selectedIndex = -1;
                                        if (widget.entry != null) {
                                          selectedIndex = snapshot.data
                                              .indexWhere((element) =>
                                          element.id ==
                                              widget.entry.mWallet.id);
                                          _selectedWallet =
                                              widget.entry.mWallet;
                                        }
                                        return ChipGroup(
                                            snapshot.data
                                                .map((e) => e.name)
                                                .toList(),
                                            chipColors: snapshot.data
                                                .map((e) => e.color)
                                                .toList(),
                                            selectedIndex: selectedIndex,
                                            onChipSelectedCallback:
                                                (List<int> index) {
                                              _selectedWallet =
                                              snapshot.data[index[0]];
                                            });
                                      } else {
                                        return ChipGroup([]);
                                      }
                                    },
                                  )),
                              StreamBuilder(
                                stream:
                                BlocProvider.of<AddEntryBloc>(context).tags,
                                builder: (context,
                                    AsyncSnapshot<List<tag>> snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data.length > 0) {
                                    int selectedIndex = -1;
                                    if (widget.entry != null &&
                                        widget.entry.mTag != null) {
                                      selectedIndex = snapshot.data.indexWhere(
                                              (element) =>
                                          element.id ==
                                              widget.entry.mTag.id);
                                      _selectedTag = widget.entry.mTag;
                                    }
                                    return Column(
                                      children: [
                                        Container(
                                            width: double.maxFinite,
                                            margin: EdgeInsets.only(
                                                left: 10.0,
                                                top: 20.0,
                                                right: 0.0,
                                                bottom: 0.0),
                                            child: Text(
                                              "Tag",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                              ),
                                            )),
                                        Container(
                                            width: double.maxFinite,
                                            margin: EdgeInsets.only(
                                                left: 10.0,
                                                top: 10.0,
                                                right: 10.0,
                                                bottom: 0.0),
                                            child: ChipGroup(
                                              snapshot.data
                                                  .map((e) => e.name)
                                                  .toList(),
                                              chipColors: snapshot.data
                                                  .map((e) => e.color)
                                                  .toList(),
                                              cancelableIndexes: snapshot.data
                                                  .map((e) => e.canDelete)
                                                  .toList(),
                                              selectedIndex: selectedIndex,
                                              onChipSelectedCallback:
                                                  (List<int> index) {
                                                _selectedTag =
                                                snapshot.data[index[0]];
                                              },
                                              onChipCanceled: (int index) {
                                                _showDeleteConfirmationDialog(
                                                    DeleteTagEvent(
                                                        snapshot.data[index]),
                                                    "tag");
                                              },
                                            )),
                                        Container(
                                          height: 45,
                                          margin: EdgeInsets.only(
                                              left: 10.0,
                                              top: 10.0,
                                              right: 10.0,
                                              bottom: 0.0),
                                          child: RaisedButton(
                                            color: Colors.white,
                                            disabledColor: Colors.white,
                                            highlightColor: Colors.white70,
                                            splashColor:
                                            Colors.blue.withOpacity(0.2),
                                            elevation: 0,
                                            onPressed: () {
                                              _showAddTagDialog();
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              side: BorderSide(
                                                  color: Colors.blue, width: 2),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/ic_add.png",
                                                  width: 24,
                                                  height: 24,
                                                  alignment:
                                                  Alignment.centerLeft,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: Text(
                                                      "add tag".toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              Container(
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 20.0,
                                      right: 0.0,
                                      bottom: 0.0),
                                  child: Text(
                                    "Description",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  )),
                              Container(
                                  width: double.maxFinite,
                                  height: 100,
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      right: 10.0,
                                      bottom: 20.0),
                                  child: GestureDetector(
                                    child: TextFormField(
                                      maxLines: 100,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return 'Text is empty';
                                        }
                                        return null;
                                      },
                                      controller:
                                      widget._descriptionTextController,
                                      onChanged: (text) {
                                        if (text.length > 1) {
                                          widget._formKey.currentState
                                              .validate();
                                        }
                                      },
                                      decoration: InputDecoration(
                                          hintText:
                                          "Type your description here",
                                          filled: true,
                                          fillColor: Color(0xFFD3DADD),
                                          hintStyle: TextStyle(
                                              color: Color(0xFF263238)),
                                          errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3.0))),
                                          focusedErrorBorder:
                                          UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3.0))),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3.0))),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3.0)))),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: widget._offsetAnimation,
                      child: CalculatorKeyBoardView(
                        textController: widget._amountTextController,
                        callback: (value) {
                          BlocProvider.of<AddEntryBloc>(context)
                              .amountValidator
                              .sink
                              .add(value);
                        },
                      ),
                    )
                  ],
                );
              }
              return view;
            },
          ),
        ));
  }

  void _showAddCategoryDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (contextC) => CreateCategoryDialog(
              (name, color) {
            BlocProvider.of<AddEntryBloc>(context)
              ..add(CreateCategoryEvent(name, color, widget.isIncome));
          },
        ));
  }

  void _showAddTagDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (contextC) => CreateTagDialog(
              (name, color) {
            BlocProvider.of<AddEntryBloc>(context)
              ..add(CreateTagEvent(name, color, _selectedCategory.id));
          },
        ));
  }

  void _showDeleteConfirmationDialog(AddEntryEvent event, String type) {
    showDialog(
        context: context,
        builder: (contextB) {
          return AlertDialog(
            title: Text(
              "DELETE $type".toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
                "Do you really want to delete this $type? All entries related to this $type will be saved to \"Other\" $tag"),
            actions: <Widget>[
              RawMaterialButton(
                elevation: 0.0,
                highlightElevation: 0.0,
                fillColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                child: Text(
                  "yes".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  BlocProvider.of<AddEntryBloc>(context).add(event);
                  Navigator.pop(context);
                },
              ),
              RawMaterialButton(
                elevation: 0.0,
                highlightElevation: 0.0,
                fillColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                child: Text(
                  "no".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _showDatePicker() {
    showModalBottomSheetCustom(
        context: context,
        builder: (ctx) {
          return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RawMaterialButton(
                        elevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        focusElevation: 0,
                        disabledElevation: 0,
                        child: Text(
                          "cancel".toUpperCase(),
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RawMaterialButton(
                        elevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        focusElevation: 0,
                        disabledElevation: 0,
                        child: Text(
                          "select".toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                        onPressed: () {
                          _setDateToDateField(
                              widget._calendarController.selectedDay);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TableCalendar(
                          calendarController: widget._calendarController,
                          rowHeight: 55,
                          headerStyle: HeaderStyle(
                              centerHeaderTitle: true, formatButtonVisible: false
                          ),
                          calendarStyle: CalendarStyle(
                              weekendStyle: TextStyle(color: Colors.black),
                              outsideDaysVisible: false),
                        ),
                      )
                    ],
                  )
                ],
              ));
        });
  }

  void _setDateToDateField(DateTime selectedDay) {
    final formatter = DateFormat("dd-MM-yyyy");
    String date = formatter.format(selectedDay);
    widget._dateTextController.text = date;
  }
}