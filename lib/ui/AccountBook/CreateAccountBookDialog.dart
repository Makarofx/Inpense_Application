import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/ui/AccountBook/AccountBookEvents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:inpensefinal_app/ui/ColorPickerWidget.dart';
import 'package:inpensefinal_app/ui/AccountBook/AccountBookBloc.dart';

typedef void CreateAccountBookDialogCallback(String name, int color, int bookId);

class CreateAccountBookDialog extends StatelessWidget {

  final CreateAccountBookDialogCallback callback;
  final account_book book;

  CreateAccountBookDialog({this.book, this.callback});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Provider(
            create: (_) => callback,
            child: AccountBookForm(book: book,),
          ),
        ),
        onWillPop: () {}
    );
  }
}

//class DialogContent extends StatefulWidget {
//
//}

class AccountBookForm extends StatefulWidget {

  final account_book book;

  AccountBookForm({this.book});

  @override
  State createState() {
    return AccountBookFormState();
  }
}

class AccountBookFormState extends State<AccountBookForm> {

  int state = 0;
  int color = -1;
  final _formKey = GlobalKey<FormState>();
  final accountNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if(widget.book != null) {
      accountNameTextController.text = widget.book.name;
      if(color == -1) {
        color = widget.book.color;
      }
    }
    return Stack(
      children: [
        state == 0 ? _showFirstState() : _showSecondState()
      ],
    );
  }

  Widget _showFirstState() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(2.0))
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: EdgeInsets.only(
                    top: 15.0,
                    left: 10.0
                ),
                width: double.maxFinite,
                child: Text(
                  widget.book == null ? "CREATE ACCOUNT BOOK" : "EDIT ACCOUNT BOOK",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                )
            ),
            Container(
                margin: EdgeInsets.only( top: 15.0),
                child: Divider(
                  height: 1,
                  color: Colors.blueGrey,
                )
            ),
            Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(
                    left: 10.0,
                    top: 20.0,
                    right: 0.0,
                    bottom: 0.0),
                child: Text(
                  "Name",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                )
            ),
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(
                  left: 10.0,
                  top: 10.0,
                  right: 10.0,
                  bottom: 0.0),
              child: TextFormField(
                maxLines: 1,
                controller: accountNameTextController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Text is empty';
                  }
                  return null;
                },
                onChanged: (text) {
                  if(text.length > 1) {
                    _formKey.currentState.validate();
                  }
                },
                decoration: InputDecoration(
                    hintText: "Enter name",
                    filled: true,
                    fillColor: Color(0xFFD3DADD),
                    hintStyle: TextStyle(
                        color: Color(0xFF263238)
                    ),
                    errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    )
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                    left: 10.0,
                    top: 10.0,
                    right: 10.0,
                    bottom: 10.0),
                child: Container(
                  width: double.maxFinite,
                  height: 40.0,
                  child: RawMaterialButton(
                    fillColor: Color(color == -1 ? 0xFF455A64 : color),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    child: Text(
                      "choose color".toUpperCase(),
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: () {
                      state = 1;
                      setState(() {

                      });
                    },
                  ),
                )
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RawMaterialButton(
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    fillColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    child: Text(
                      "cancel".toUpperCase(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () => {
                      Navigator.pop(context)
                    },
                  ),
                  RawMaterialButton(
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    fillColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0))
                    ),
                    child: Text(
                      "create".toUpperCase(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      if(_formKey.currentState.validate() && color != -1) {
                        context.read<CreateAccountBookDialogCallback>().call(
                            accountNameTextController.text.toString(),
                            color,
                            widget.book == null ? null : widget.book.id);
                        Navigator.pop(context);
                      } else {
                        if(color == -1) {
                          Fluttertoast.showToast(
                              msg: "Choose a color",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      }
                    },
                  ),
                ]
            )
          ],
        ),
      ),
    );
  }

  Widget _showSecondState() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(2.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              margin: EdgeInsets.only(
                  top: 15.0,
                  left: 10.0
              ),
              width: double.maxFinite,
              child: Text(
                "CHOOSE COLOR",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                ),
              )
          ),
          Container(
              margin: EdgeInsets.only( top: 15.0),
              child: Divider(
                height: 1,
                color: Colors.blueGrey,
              )
          ),
          Container(
              width: double.maxFinite,
              height: 150.0,
              margin: EdgeInsets.only(
                  left: 10.0,
                  top: 20.0,
                  right: 10.0,
                  bottom: 0.0),
              child: ColorPickerWidget(
                callback: (int color) {
                  this.color = color;
                },
              )
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RawMaterialButton(
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  fillColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Text(
                    "cancel".toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () {
                    this.color = -1;
                    setState((){
                      state = 0;
                    });
                  },
                ),
                RawMaterialButton(
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  fillColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Text(
                    "choose".toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () {
                    if(color == -1) {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg: "Choose a color",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    } else {
                      state = 0;
                      setState(() {});
                    }
                  },
                ),
              ]
          )
        ],
      ),
    );
  }
}