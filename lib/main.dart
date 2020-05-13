import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.blue,
            brightness: brightness,
            fontFamily: 'Serif',
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  button: TextStyle(color: Colors.white),
                ),
            appBarTheme: AppBarTheme(
              textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            )),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'Money List',
            theme: theme,
            home: MyHomePage(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];

  void toggleLightDarkTheme() {
    if (Theme.of(context).brightness == Brightness.dark) {
      DynamicTheme.of(context).setThemeData(ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          accentColor: Colors.amber));
    } else {
      DynamicTheme.of(context).setThemeData(ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          accentColor: null));
    }
  }

  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Money List',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.brightness_solid),
                  onTap: () => toggleLightDarkTheme(),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                ),
                GestureDetector(
                  child: Icon(CupertinoIcons.add_circled_solid),
                  onTap: () => _startAddNewTransaction(context),
                )
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Money List',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.brightness_4),
                onPressed: () => toggleLightDarkTheme(),
              ),
              Container(
                padding: EdgeInsets.only(right: 8),
              ),
              
            ],
          );

    final txListWidget = Container(
      height: (mediaQuery.size.height * 0.7) - appBar.preferredSize.height,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isLandscape)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Show Chart',
                      style: Theme.of(context).textTheme.title,
                    ),
                    Switch.adaptive(
                      activeColor: Theme.of(context).accentColor,
                      value: _showChart,
                      onChanged: (val) {
                        setState(() {
                          _showChart = val;
                        });
                      },
                    ),
                  ],
                ),
              if (!isLandscape)
                Container(
                  height: (mediaQuery.size.height * 0.3) -
                      appBar.preferredSize.height,
                  child: Chart(_recentTransactions),
                ),
              if (!isLandscape) txListWidget,
              if (isLandscape)
                _showChart
                    ? Container(
                        height: (mediaQuery.size.height * 0.55),
                        child: Chart(_recentTransactions),
                      )
                    : txListWidget
            ]),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}