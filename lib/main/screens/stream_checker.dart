import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StreamChecker extends StatefulWidget {
  const StreamChecker({Key? key}) : super(key: key);

  @override
  _StreamCheckerState createState() => _StreamCheckerState();
}

class _StreamCheckerState extends State<StreamChecker> {
  String allResponse = "";

  Future<void> checker() async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream', // Set Accept header for SSE
      'Authorization': 'Bearer 9d3d9157-9554-4564-b965-55aed69f',
    };

    try {
      var request =
          http.Request('POST', Uri.parse("https://api.corcel.io/cortext/text"))
            ..headers.addAll(headers)
            ..body = json.encode({
              "messages": [
                {"role": "user", "content": "What is python in 100 words"}
              ],
              "model": "cortext-ultra",
              "stream": true,
              "miners_to_query": 1,
              "top_k_miners_to_query": 40,
              "ensure_responses": false
            });

      // Send the request and open the SSE connection
      var response = await http.Client().send(request);
      var stream = response.stream;

      // Process the SSE events
      stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (String line) {
          print('SSE Event: $line');

          // Extract the content from the SSE event
          String keyword = 'data: ';
          if (line.contains(keyword)) {
            String content = line.split(keyword)[1].trim();

            String keywords = '"content": "';

            // Split the data into lines
            List<String> lines = content.split('\n');

            // Extract content values
            List<String> contentValues = lines
                .where((line) => line.contains(keywords))
                .map((line) => line.split(keywords).last.split('"').first)
                .toList();

            // Print content values
            for (var content in contentValues) {
              setState(() {
                allResponse += content;
              });
            }
          }
        },
        onDone: () {
          print('SSE Connection closed.');
        },
        onError: (error) {
          print('Error in SSE connection: $error');
          setState(() {
            allResponse = error;
          });
        },
      );
    } catch (e) {
      print('Error: $e');
      setState(() {
        allResponse = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stream Checker"),
        actions: [
          IconButton(
            onPressed: checker,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Text(allResponse),
      ),
    );
  }
}



















// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class StreamChecker extends StatefulWidget {
//   const StreamChecker({Key? key}) : super(key: key);

//   @override
//   _StreamCheckerState createState() => _StreamCheckerState();
// }

// class _StreamCheckerState extends State<StreamChecker> {
//   final _responseController = StreamController<String>();

//   Stream<String> get responseStream => _responseController.stream;

//   String allResponse = "";

//   Future<void> checker() async {
//     var headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'text/event-stream', // Set Accept header for SSE
//       'Authorization': 'Bearer cc03470f-b51d-4e1a-be31-92872b2f',
//     };

//     try {
//       var request =
//           http.Request('POST', Uri.parse("https://api.corcel.io/cortext/text"))
//             ..headers.addAll(headers)
//             ..body = json.encode({
//               "messages": [
//                 {"role": "user", "content": "What is python in 100 words"}
//               ],
//               "model": "cortext-ultra",
//               "stream": true,
//               "miners_to_query": 1,
//               "top_k_miners_to_query": 40,
//               "ensure_responses": false
//             });

//       // Send the request and open the SSE connection
//       var response = await http.Client().send(request);
//       var stream = response.stream;

//       // Process the SSE events
//       stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
//         (String line) {
//           print('SSE Event: $line');

//           // Extract the content from the SSE event
//           String keyword = 'data: ';
//           if (line.contains(keyword)) {
//             String content = line.split(keyword)[1].trim();

//             String keywords = '"content": "';

//             // Split the data into lines
//             List<String> lines = content.split('\n');

//             // Extract content values
//             List<String> contentValues = lines
//                 .where((line) => line.contains(keywords))
//                 .map((line) => line.split(keywords).last.split('"').first)
//                 .toList();

//             // Print content values
//             for (var content in contentValues) {
//               _responseController.add(content);
//               setState(() {
//                 allResponse += content;
//               });
//             }
//           }
//         },
//         onDone: () {
//           print('SSE Connection closed.');
//         },
//         onError: (error) {
//           print('Error in SSE connection: $error');
//           _responseController.addError(error);
//         },
//       );
//     } catch (e) {
//       print('Error: $e');
//       _responseController.addError(e);
//     }
//   }

//   @override
//   void dispose() {
//     _responseController.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Stream Checker"),
//         actions: [
//           IconButton(
//             onPressed: checker,
//             icon: const Icon(Icons.check),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Text(allResponse),
//         // StreamBuilder<String>(
//         //   stream: responseStream,
//         //   builder: (context, snapshot) {
//         //     if (snapshot.connectionState == ConnectionState.waiting) {
//         //       return const CircularProgressIndicator();
//         //     } else if (snapshot.hasError) {
//         //       return Text('Error: ${snapshot.error}');
//         //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//         //       return Text(allResponse);
//         //     } else {
//         //       return Padding(
//         //         padding: const EdgeInsets.all(16.0),
//         //         child: Text(
//         //           allResponse,
//         //         ),
//         //       );
//         //     }
//         //   },
//         // ),
//       ),
//     );
//   }
// }
