import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:nigeria_bank_account_verifier/user.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'bank.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nigeria Bank Account Verifier',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Nigeria Bank Account Verifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedPosition = 0;
  String dropdownValue = 'Abbey Mortgage Bank';
  String name = "";

  final accountNumberController = TextEditingController();

//  TextEditingController emailController = new TextEditingController();

  List bankCodes = [];
  List<String> bankNames = [];

  // Fetch content from the json file
  Future<void> localJsonData() async {
    final String response =
        await rootBundle.loadString('assets/bankcodes.json');
    final List _bankCodes = json.decode(response);
    bankCodes.clear();
    List<String> _bankNames = [];
    for (int i = 0; i < _bankCodes.length; i++) {
      _bankNames.add(_bankCodes[i]['name']);
    }

    setState(() {
      bankCodes.addAll(_bankCodes);
      bankNames = _bankNames;
    });
  }

  void fetchUser(String acctNo, String bankCode) async {
    showLoaderDialog(context);

    String token = "sk_live_c2344eba5f22c31db42a2c2fc3f512badb8e65b8";
    final response = await http.get(
        Uri.parse(
            'https://api.paystack.co/bank/resolve?account_number=$acctNo&bank_code=$bankCode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body)['message']);

      //   User user = jsonDecode(response.body);
      User user = User.fromJson(json.decode(response.body));

      print(user.data.accountName);

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserDetailsPage(
                  user: user,
                )),
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      Navigator.pop(context);
      showAlert(context, "Failed to load account number");
      // throw Exception('Failed to load account number');
    }
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Message"),
              content: Text(message),
            ));
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    this.localJsonData();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(15.0),
              child: Text(
                'Select Bank',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              margin: EdgeInsets.only(left: 15.0, right: 15.0),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent)
              ),
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                iconSize: 30,
                hint: Text('Select a Bank'),
                icon: Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: TextStyle(color: Colors.black, fontSize: 20),

                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                    _selectedPosition = bankNames.indexOf(dropdownValue);
                  });
                },
                items: bankNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 25.0, bottom: 15.0),
              child: Text(
                // '' + _selectedPosition.toString(),
                'Enter Account Number',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: TextField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Account Number'),
             style: TextStyle(
                 fontSize: 20.0,),
              ),
            ),
            Container(
                margin: EdgeInsets.all(15.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // print(await http.read(Uri.parse(
                    //     'https://flutter.dev/docs/cookbook/networking/fetch-data')));

                    // print(accountNumberController.text);
                    // print(bankCodes.length);
                    // print(bankNames.length);


                    if (_selectedPosition == -1) {
                      showAlert(context, 'Kindly select a valid bank');
                      return;
                    }

                    if (accountNumberController.text.toString().toLowerCase() == "") {
                      showAlert(context, 'Kindly enter a valid account number');
                      return;
                    }

                    fetchUser(accountNumberController.text,  bankCodes[_selectedPosition]['code']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.info),
        onPressed: () {
print('clicked');

showDialog(
    context: context,
    builder: (BuildContext context) {
      return  AlertDialog(
        title: const Text('Message'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This app uses the official publicly accessible Nibss account checker api to allow users verify an account number so as not to fall victims to scams and fraud. \n https://nibss-plc.com.ng/services/name-enquiry.'),

            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );

    });


        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  UserDetailsPage({Key key, this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Details"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0, left: 20.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Account Number:',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  user.data.accountNumber,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )
            ],
          ),
          Container(
            color: Colors.black12,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    'Account Name',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    user.data.accountName,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 40.0, left: 20.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Bank Name:',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0,bottom: 40.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  user.data.bankId.toString(),
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to first route when tapped.
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ),
        ],
      ),
    );
  }
}
