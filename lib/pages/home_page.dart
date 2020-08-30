import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:piggy_bank/models/breakdown.dart';
import 'package:piggy_bank/models/breakdowns.dart';
import 'package:piggy_bank/pages/input_page.dart';
import 'package:piggy_bank/pages/updatePage.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> _selection = [true, false, false];
  double _opacity = 0.0;

  Future<void> scratchCardDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'You\'ve won a scratch card',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            return Scratcher(
              accuracy: ScratchAccuracy.low,
              threshold: 25,
              brushSize: 50,
              color: Colors.green,
              onThreshold: () {
                setState(() {
                  _opacity = 1;
                });
              },
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 250),
                opacity: _opacity,
                child: Container(
                  height: 300,
                  width: 300,
                  alignment: Alignment.center,
                  child: Text(
                    "200",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.blue),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Breakdowns breakdowns = Provider.of<Breakdowns>(context);
    return Scaffold(
      body: buildBody(breakdowns),
      floatingActionButton: floatingButton(breakdowns),
    );
  }

  buildBody(Breakdowns breakdowns) {
    return SafeArea(
        child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
        ),
        _typePicker(),
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
        ),
        Expanded(
          child: breakdownsList(breakdowns),
        ),
        totalMoney(breakdowns)
      ],
    ));
  }

  _typePicker() {
    return Container(
      height: 40,
      child: ToggleButtons(
        isSelected: _selection,
        children: <Widget>[
          Container(
              width: (MediaQuery.of(context).size.width - 54) / 3,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "all",
                  )
                ],
              )),
          Container(
              width: (MediaQuery.of(context).size.width - 36) / 3,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("Income")],
              )),
          Container(
              width: (MediaQuery.of(context).size.width - 36) / 3,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("expenditure")],
              )),
        ],
        borderColor: Colors.white,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        borderWidth: 1,
        fillColor: Colors.grey,
        selectedColor: Colors.white,
        onPressed: (int index) {
          setState(() {
            _selection[index] = true;
            if (index == 0) {
              _selection[1] = false;
              _selection[2] = false;
            } else if (index == 1) {
              _selection[0] = false;
              _selection[2] = false;
            } else {
              _selection[0] = false;
              _selection[1] = false;
            }
          });
        },
      ),
    );
  }

  breakdownsList(Breakdowns breakdowns) {
    List<Breakdown> list = breakdowns.breakdowns;
    if (_selection[0]) {
      return ListView(
          children: List.generate(list.length, (i) => breakdownCard(list[i])));
    } else if (_selection[1]) {
      return ListView(
          children: List.generate(
              list.length,
              (i) => list[i].type == 'income'
                  ? breakdownCard(list[i])
                  : Container()));
    } else if (_selection[2]) {
      return ListView(
          children: List.generate(
              list.length,
              (i) => list[i].type == 'income'
                  ? Container()
                  : breakdownCard(list[i])));
    }
  }

  breakdownCard(Breakdown breakdown) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Card(
            color: breakdown.type == 'income'
                ? Color.fromRGBO(120, 180, 120, 1)
                : Color.fromRGBO(180, 120, 120, 1),
            child: ListTile(
              onTap: () {
                itemClick(breakdown);
              },
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${breakdown.month}/${breakdown.day}',
                      style: TextStyle(fontSize: 14)),
                  Text(
                      '${addZero(breakdown.hour)}:${addZero(breakdown.minute)}',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              title: Text(breakdown.category, style: TextStyle(fontSize: 21)),
              trailing: breakdown.type == 'income'
                  ? Text(
                      '${FlutterMoneyFormatter(amount: breakdown.cost.toDouble()).output.withoutFractionDigits}/-',
                      style: TextStyle(fontSize: 18))
                  : Text(
                      '-${FlutterMoneyFormatter(amount: breakdown.cost.toDouble()).output.withoutFractionDigits}/-',
                      style: TextStyle(fontSize: 18)),
            ),
          ),
          breakdown.type == 'income' && breakdown.cost >= 500
              ? Container(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    onPressed: () => scratchCardDialog(context),
                    child: Text(
                      "Won Scratch Card",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                )
              : Container(
                  child: Text(" "),
                )
        ],
      ),
    );
  }

  floatingButton(Breakdowns breakdowns) {
    return FloatingActionButton(
      child: Icon(
        Icons.add,
        size: 30,
      ),
      backgroundColor: Colors.white,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => InputPage()));
      },
    );
  }

  totalMoney(Breakdowns breakdowns) {
    int height = MediaQuery.of(context).size.height.toInt();
    // ignore: unused_local_variable
    double width = MediaQuery.of(context).size.width.toDouble();
    return Container(
      height: height * 0.1,
      color: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: <Widget>[
            Text(
              'left money : ${FlutterMoneyFormatter(amount: breakdowns.totalMoney.toDouble()).output.withoutFractionDigits}/-',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String addZero(int num) {
    if (num < 10)
      return '0' + num.toString();
    else
      return num.toString();
  }

  itemClick(Breakdown breakdown) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdatePage(
                  breakdown: breakdown,
                )));
  }
}
