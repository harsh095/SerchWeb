import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
class WebViewSerch extends StatefulWidget {
  const WebViewSerch({super.key});

  @override
  State<WebViewSerch> createState() => _WebViewSerchState();
}

class _WebViewSerchState extends State<WebViewSerch> {
  final GlobalKey webViewKey = GlobalKey();
  bool serch=false;


  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings();
  late FindInteractionController findInteractionController;

  final searchController = TextEditingController();
  final replaceController = TextEditingController();

  var textFound = "";
void data(String a, String b)
{

  print("HArsh");
  webViewController!.evaluateJavascript(source: """
              var elements = document.getElementsByTagName('*');
              for (var i = 0; i < elements.length; i++) {
                var element = elements[i];
                element.innerHTML = element.innerHTML.replace(/$a/g, '$b');
              }
            """);
}
  @override
  void initState() {
    super.initState();

    findInteractionController = FindInteractionController(
      onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches,
          isDoneCounting) async {
        if (isDoneCounting) {
          serch=true;
          setState(() {
            textFound = numberOfMatches > 0
                ? '${activeMatchOrdinal + 1} of $numberOfMatches'
                : '';
          });
          if (numberOfMatches == 0) {
            serch=false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'No matches found for "${await findInteractionController.getSearchText()}"'),
            ));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var isFindInteractionEnabled = settings.isFindInteractionEnabled ?? false;

    return Scaffold(
        appBar: AppBar(
            title: const Text('Wev View Serch'),
            actions: defaultTargetPlatform != TargetPlatform.iOS
                ? []
                : [
              (isFindInteractionEnabled)
                  ? IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  if (await findInteractionController
                      .isFindNavigatorVisible() ??
                      false) {
                    await findInteractionController
                        .dismissFindNavigator();
                  } else {
                    await findInteractionController
                        .presentFindNavigator();
                  }
                },
              )
                  : Container(),
              TextButton(
                style:
                TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  if (isFindInteractionEnabled) {
                    searchController.text =
                        await findInteractionController.getSearchText() ??
                            '';
                  }
                  await findInteractionController.clearMatches();
                  isFindInteractionEnabled =
                      settings.isFindInteractionEnabled =
                  !isFindInteractionEnabled;
                  await webViewController?.setSettings(
                      settings: settings);
                  setState(() {
                    textFound = '';
                  });
                  await findInteractionController
                      .setSearchText(searchController.text);
                  if (isFindInteractionEnabled) {
                    await findInteractionController
                        .presentFindNavigator();
                  }
                },
                child: Text(!isFindInteractionEnabled
                    ? 'Native UI'
                    : 'Custom UI'),
              )
            ]),
        body: Column(children: <Widget>[

          isFindInteractionEnabled
              ? Container()
              : Padding(
                padding:EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                child: TextField(

            decoration: InputDecoration(
                hintText: "Serch Any Data",
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixText: textFound,
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        findInteractionController.findNext(forward: false);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        findInteractionController.findNext();
                      },
                    ),
                  ],
                ),
            ),
            controller: searchController,
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
                if (value == '') {
                  findInteractionController.clearMatches();
                  setState(() {
                    textFound = '';
                  });
                } else {
                  findInteractionController.findAll(find: value);


                }
            },
          ),
              ),
          isFindInteractionEnabled
              ? Container()
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                child: TextField(
controller: replaceController,

            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Replace any Data",

              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color:
                      Colors.blue
                  ),
                ),

            ),
            onSubmitted: (value) {
                if (value == '') {
                  findInteractionController.clearMatches();
                  setState(() {
                    textFound = '';
                  });
                } else {
                  if(serch==false&&searchController.text.isEmpty)
                    {
                      Fluttertoast.showToast(msg: "Your Serch is not there");
                    }
                  else if(replaceController.text.isEmpty)
                    {
                      Fluttertoast.showToast(msg: "Replace Feild can't be empty");
                    }
                  else
                    {
                      data(searchController.text.toString(),value.toString());
                    }
                }
            },
          ),
              ),

          Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri("https://flutter.dev/")),
                findInteractionController: findInteractionController,

                initialSettings: settings,
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                },
              )),
        ]));
  }
}