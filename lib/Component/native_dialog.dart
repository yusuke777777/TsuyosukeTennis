import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../Page/Billing.dart';

class ShowDialogToDismiss extends StatelessWidget {
  final String content;

  // final String title;
  final String buttonText;

  const ShowDialogToDismiss({Key? key, required this.content,required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        content,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.lightGreenAccent, onPrimary: Colors.black),
          child: Text(buttonText),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class BillingShowDialogToDismiss extends StatelessWidget {
  final String content;

  // final String title;
  // final String buttonText;

  const BillingShowDialogToDismiss({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        content,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.lightGreenAccent, onPrimary: Colors.black),
          child: Text('はい'),
          onPressed: () async {
            final offerings = await Purchases.getOfferings();
            if (offerings == null || offerings.current == null) {
              // offerings are empty, show a message to your user
            } else {
              Package? tspPlan = offerings!.current!.getPackage("TSP0001");

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Billing(tspPlan: tspPlan!)),
              );
            }
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.lightGreenAccent, onPrimary: Colors.black),
          child: Text('いいえ'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}