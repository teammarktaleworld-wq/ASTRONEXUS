import 'package:flutter/material.dart';

class StepOtp extends StatelessWidget {
  final Function(String) onVerify;

  const StepOtp({super.key, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      children: [
        Text("Enter OTP"),
        TextField(controller: controller, keyboardType: TextInputType.number),
        ElevatedButton(
          onPressed: () => onVerify(controller.text),
          child: const Text("Verify OTP"),
        ),
      ],
    );
  }
}
