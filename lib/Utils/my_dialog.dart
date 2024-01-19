import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/helpers.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:lisa_ai/main/main_conntroller.dart';

class MyDialog {
  static bool isSaving = false;

  static void showApiKeyDialog(
      BuildContext context, MainController controller) {
    TextEditingController apiKeyController = TextEditingController();
    apiKeyController.text = SharedPrefsUtils.getApiKey() ?? "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          // Prevent dialog from being dismissed on back press
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Enter API Key'),
            content: TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(labelText: 'API Key'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (isSaving) {
                    Helper.showMyToast("Please wait...");

                    return; // Prevent multiple clicks while saving
                  }
                  isSaving = true; // Set flag to indicate save is in progress
                  Helper.showMyToast("Please wait...");

                  print(apiKeyController.text);

                  if (apiKeyController.text.isEmpty) {
                    Helper.showMyToast("Enter Api Key");
                    isSaving = false;
                    return;
                  }

                  Helper.showMyToast("Please wait...");

                  bool isCorrect =
                      await controller.isApiKeyCorrect(apiKeyController.text);

                  if (isCorrect) {
                    await SharedPrefsUtils.setApiKey(
                        apiKeyController.text.trim());
                    Get.back();
                  }

                  isSaving = false; // Reset the flag after saving is complete
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
