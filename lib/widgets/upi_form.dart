import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_qr_code_generator/consts.dart';
import '../providers/upi_provider.dart';
import '../screens/qr_code.dart';

class UpiForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  UpiForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upiController = TextEditingController();
    final amountController = TextEditingController();
    final nameController = TextEditingController();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (kIsWeb)
            Image.network(
              'assets/ico.png',
              height: MediaQuery.sizeOf(context).height * 0.25,
            )
          else
            Image.asset(
              'assets/ico.png',
              height: MediaQuery.sizeOf(context).height * 0.25,
            ),
          const SizedBox(height: 20),
          TextFormField(
            controller: upiController,
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            cursorColor: Colors.black,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter UPI ID';
              }
              if (!RegExp(UPI_REGEX).hasMatch(value)) {
                return 'Please enter a valid UPI ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            cursorColor: Colors.black,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            cursorColor: Colors.black,
            keyboardType: TextInputType.numberWithOptions(),
            inputFormatters: <TextInputFormatter>[
              // FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final upiId = upiController.text;
                final name = nameController.text;
                final amount = amountController.text;
                final upiUri = 'upi://pay?pa=$upiId&pn=$name&am=$amount';
                ref.read(upiProvider.notifier).state = upiUri;
                if (upiUri != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrDisplayScreen(),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: const BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }
}
