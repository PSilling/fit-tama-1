import 'dart:async';
import 'dart:math';

import 'package:dashboard/dashboard.dart';
import 'package:tabletop_assistant/storage.dart';

import 'package:flutter/material.dart';

import 'add_dialog.dart';
import 'data_widget.dart';

///
void main() {
  ///
  runApp(const MyApp());
}

///
class MyApp extends StatefulWidget {
  ///
  const MyApp({Key? key}) : super(key: key);

  ///
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ///
  Color getRandomColor() {
    var r = Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard online demo',
      onGenerateInitialRoutes: (r) {
        return r == "/dashboard"
            ? [
          MaterialPageRoute(builder: (c) {
            return const DashboardWidget();
          })
        ]
            : [
          MaterialPageRoute(builder: (c) {
            return const MainPage();
          })
        ];
      },
      initialRoute: "/",
      routes: {
        "/": (c) => const MainPage(),
        "/dashboard": (c) => const DashboardWidget()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class MenuItem {
  final String name;
  final int id;

  MenuItem({
    required this.name,
    required this.id
  });
}

class _MainPageState extends State<MainPage> {

  void _addDashboard(){
    // some code to add new dashboard, show add
    setState(() {
      var newId = Random().nextInt(100000) + 4;
      menuItems.add(
        MenuItem(
            name: 'Bar ' + newId.toString(),
            id: newId
        )
      );
    });
  }

  void _removeDashboard(id){
    if (menuItems.length <= 1){
      editingMode = false;
    }
    setState(() {
      menuItems.removeWhere((item) => item.id == id);
    });
  }

  void _placeholderFc(){}

  var editingMode = false;
  var menuItems = <MenuItem>[
    MenuItem(name: 'lol', id: 1)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main menu'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: _placeholderFc,
              icon: const Icon(Icons.search)
          ),
          IconButton(
              onPressed: _placeholderFc,
              icon: const Icon(Icons.sort)
          ),
          IconButton(
              onPressed: _placeholderFc,
              icon: const Icon(Icons.more_vert)
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black54
        ),
        child: Padding(
            padding: const EdgeInsets.all(0),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3/4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8
              ),
              itemCount: menuItems.length,
              itemBuilder: (BuildContext context, index) {
                var myMenuItem = menuItems[index];
                return GestureDetector(
                    onTap: () {
                      if(!editingMode){
                        Navigator.pushNamed(context, "/dashboard");
                      }
                    },
                    onLongPress: () {
                      editingMode = !editingMode;
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black87.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 7,
                                offset: const Offset(0, 5)
                            )
                          ]
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: <Widget>[
                              const ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)
                                  ),
                                  child: Image(
                                    image: AssetImage('assets/placeholder.png'),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.fitHeight,
                                  )
                              ),
                              ListTile(
                                title: Text(myMenuItem.name),
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                          if (editingMode)
                            Positioned(
                              right: 5,
                              top: 5,
                              child: InkResponse(
                                radius: 20,
                                onTap: () {
                                  _removeDashboard(myMenuItem.id);
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                  size: 20,
                                )
                              )
                            )
                        ],
                      )
                    )
                );
              },
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDashboard,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
      ),
    );
  }
}

class DashboardWidget extends StatefulWidget {
  ///
  const DashboardWidget({Key? key}) : super(key: key);

  ///
  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  ///
  final ScrollController scrollController = ScrollController();

  ///
  late var itemController =
      DashboardItemController<ColoredDashboardItem>.withDelegate(
          itemStorageDelegate: storage);

  bool refreshing = false;

  var storage = MyItemStorage();

  int? slot;

  setSlot() {
    setState(() {
      slot = 2;
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    slot = 2;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Test title'),
        actions: [
          IconButton(
              onPressed: () {
                itemController.clear();
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                add(context);
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                itemController.isEditing = !itemController.isEditing;
                setState(() {});
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(
        child:
          Dashboard<ColoredDashboardItem>(
            shrinkToPlace: false,
            slideToTop: true,
            absorbPointer: false,
            padding: const EdgeInsets.all(8),
            horizontalSpace: 8,
            verticalSpace: 8,
            slotAspectRatio: 1,
            animateEverytime: true,
            scrollController: ScrollController(),
            dashboardItemController: itemController,
            slotCount: slot!,
            errorPlaceholder: (e, s) {
               return Text("$e , $s");
            },
            itemStyle: ItemStyle(
              color: Colors.transparent,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
            editModeSettings: EditModeSettings(
              paintBackgroundLines: false,
              fillEditingBackground: false,
              resizeCursorSide: 0, // when set to 0 user cannot change the shape of the widgets
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 300),
            ),
            itemBuilder: (ColoredDashboardItem item) {
              var layout = item.layoutData;

              if (item.data != null) {
                return DataWidget(
                  item: item,
                );
              }

              return Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(10)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Text(
                        "Subject to change \n ID: ${item.identifier}\n${[
                          "x: ${layout.startX}",
                          "y: ${layout.startY}",
                          "w: ${layout.width}",
                          "h: ${layout.height}",
                          if (layout.minWidth != 1)
                            "minW: ${layout.minWidth}",
                          if (layout.minHeight != 1)
                            "minH: ${layout.minHeight}",
                          if (layout.maxWidth != null)
                            "maxW: ${layout.maxWidth}",
                          if (layout.maxHeight != null)
                            "maxH : ${layout.maxHeight}"
                        ].join("\n")}",
                        style: const TextStyle(color: Colors.white),
                      )),
                  ),
                  if (itemController.isEditing)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: InkResponse(
                        radius: 20,
                        onTap: () {
                          itemController.delete(item.identifier);
                        },
                        child: const Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 20,
                        )
                      )
                    )
                    ],
                  );
                },
          ),
      ),
    );
  }

  Future<void> add(BuildContext context) async {
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const AddDialog();
        });

    if (res != null) {
      itemController.add(ColoredDashboardItem(
          color: res[6],
          width: res[0],
          height: res[1],
          identifier: (Random().nextInt(100000) + 4).toString(),
          minWidth: res[2],
          minHeight: res[3],
          maxWidth: res[4] == 0 ? null : res[4],
          maxHeight: res[5] == 0 ? null : res[5]));
    }
  }
}
