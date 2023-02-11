import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(
          height: 15,
        ),
        Center(
          child: CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 4,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Loading. Data fetching from server. Please wait..",
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
