import 'package:flutter/material.dart';

class DeliveryChargeDialog extends StatefulWidget {
  @override
  _DeliveryChargeDialogState createState() => _DeliveryChargeDialogState();
}

class _DeliveryChargeDialogState extends State<DeliveryChargeDialog> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Delivery Charge'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Delivery Charge',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop({"status": "cancel"}),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            // Pass the delivery charge back to the calling widget
            Navigator.of(context).pop(
              {
                "status": "ok",
                "rate": double.parse(_controller.text),
              },
            );
          },
        ),
      ],
    );
  }
}
