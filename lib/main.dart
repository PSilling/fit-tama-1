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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard online demo',
      onGenerateInitialRoutes: (r) {
        return [
          MaterialPageRoute(builder: (c) {
            return const DashboardWidget();
          })
        ];
      },
      initialRoute: "/",
      routes: {
        "/": (c) => const DashboardWidget(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        backgroundColor: const Color(0xFF4285F4),
        automaticallyImplyLeading: false,
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
        child: refreshing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Dashboard<ColoredDashboardItem>(
                shrinkToPlace: false,
                slideToTop: true,
                absorbPointer: false,
                padding: const EdgeInsets.all(8),
                horizontalSpace: 8,
                verticalSpace: 8,
                slotAspectRatio: 1,
                animateEverytime: true,
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
                    fillEditingBackground: true,
                    resizeCursorSide: 15,
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
                                )))
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
