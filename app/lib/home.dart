import 'dart:convert';

import 'package:app/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  TextEditingController key = TextEditingController();
  bool isKeyNotFound = false;

  void onSaveKey() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('${Config.url}/key'));
    request.body = json.encode({"key": key.text});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacementNamed('/status');
    } else {
      isKeyNotFound = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: ListView(
              children: [
                Padding(padding: EdgeInsets.only(top: 20)),
                if (isKeyNotFound)
                  Center(
                      child: Text(
                    'Key not found',
                    style: TextStyle(color: Colors.red),
                  )),
                Center(child: Text('Please enter validation key')),
                TextField(
                    controller: key,
                    decoration: InputDecoration(hintText: ':key')),
                Padding(padding: EdgeInsets.only(top: 20)),
                ElevatedButton(onPressed: onSaveKey, child: Text('Save'))
              ],
            )));
  }
}
