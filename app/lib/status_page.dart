import 'dart:async';
import 'dart:convert';

import 'package:app/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class StatusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatusPageState();
  }
}

class _StatusPageState extends State<StatusPage> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  Color statusColor = Colors.green;

  void callAPI(data) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('${Config.url}/message-and-status'));
    request.body = json.encode(data);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }
    setState(() {});
  }

  void callPermision(bool isCallAPI) async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox,
          SmsQueryKind.sent,
        ],
        // address: '+254712345789',
        // count: 10,
      );
      debugPrint('sms inbox messages: ${messages.length}');
      messages.sort((a, b) => b.date!.compareTo(a.date!));
      var newMessage = messages.sublist(0, 50);
      if (isCallAPI) {
        List<SmsMessage> unsendMessage = [];
        for (SmsMessage smsMessage in messages) {
          var dateLast10Minute = DateTime.now().subtract(Duration(minutes: 10));
          if (smsMessage.date!.compareTo(dateLast10Minute) == 1) {
            unsendMessage.add(smsMessage);
          }
        }
        if (unsendMessage.length == 0) {
          callAPI({'type': 'status'});
        } else {
          unsendMessage.forEach((e) async {
            callAPI({'type': 'message', 'message': e.body, 'date': e.date});
          });
        }
      }
      setState(() => _messages = newMessage);
    } else {
      await Permission.sms.request();
    }
  }

  @override
  void initState() {
    callPermision(false);
    Timer.periodic(Duration(seconds: 10), (t) {
      callPermision(true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SMS App'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: _messages.isNotEmpty
              ? _MessagesListView(
                  messages: _messages,
                )
              : Center(
                  child: Text(
                    'No messages to show.\n Tap refresh button...',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
        ));
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) {
          return Container(
            width: 100.0,
            height: 100.0,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.green),
          );
        } else {
          var message = messages[i];
          return ListTile(
            title: Text('${message.sender} [${message.date}]'),
            subtitle: Text('${message.body}'),
          );
        }
      },
    );
  }
}
