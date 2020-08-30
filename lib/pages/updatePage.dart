import 'package:flutter/material.dart';
import 'package:piggy_bank/database/dbHelper.dart';
import 'package:piggy_bank/models/breakdown.dart';
import 'package:piggy_bank/models/breakdowns.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class UpdatePage extends StatefulWidget {
  Breakdown breakdown;

  UpdatePage({Key key, @required this.breakdown}) : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState(breakdown);
}

class _UpdatePageState extends State<UpdatePage> {
  Breakdown breakdown;

  _UpdatePageState(this.breakdown);

  String type;
  final costController = TextEditingController();
  final categoryController = TextEditingController();
  final focusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    type = breakdown.type;
    costController.text = breakdown.cost.toString();
    categoryController.text = breakdown.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Breakdowns breakdowns = Provider.of<Breakdowns>(context);
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDialog(breakdowns);
                },
              ),
            ),
          ],
          backgroundColor: Color.fromRGBO(48, 48, 48, 1),
          elevation: 0,
        ),
        body: buildBody(breakdowns),
      ),
    );
  }

  buildBody(Breakdowns breakdowns) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          radio(),
          inputCost(),
          inputCategory(),
          Buttons(breakdowns)
        ],
      ),
    );
  }

  radio() {
    return Row(
      children: <Widget>[
        Text('Income'),
        Radio(
          value: 'income',
          groupValue: type,
          onChanged: (String value) {
            setState(() {
              type = value;
            });
          },
        ),
        Text('Spending'),
        Radio(
          value: 'spending',
          groupValue: type,
          onChanged: (String value) {
            setState(() {
              type = value;
            });
          },
        )
      ],
    );
  }

  inputCost() {
    return TextField(
      controller: costController,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: 'Price'),
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
    );
  }

  inputCategory() {
    return TextField(
      controller: categoryController,
      maxLength: 10,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Contents',
      ),
      onEditingComplete: () {},
    );
  }

  // ignore: non_constant_identifier_names
  Buttons(Breakdowns breakdowns) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text("cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
        ),
        RaisedButton(
          child: Text("complete"),
          onPressed: () {
            onUpdate(breakdowns);
          },
        )
      ],
    );
  }

  onUpdate(Breakdowns breakdowns) {
    if (costController.text == '') {
      final snackBar = SnackBar(
        content: Text('Please enter the amount.'),
        action: SnackBarAction(
          label: 'close',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }

    breakdown.type = type;
    breakdown.cost = int.parse(costController.text);
    breakdown.category = categoryController.text;
    print(breakdown.toMap().toString());
    DBHelper.db.updateBreakdownInDB(breakdown);
    breakdowns.getFromDB();
    Navigator.pop(context);
  }

  void _showDialog(Breakdowns breakdowns) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Are you sure you want to delete?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text("Confirm"),
              onPressed: () {
                DBHelper.db.deleteBreakdownInDB(breakdown);
                breakdowns.getFromDB();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
