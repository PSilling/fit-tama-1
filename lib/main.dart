import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tabletop_assistant/table-board.dart';

import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

import './menu-item.dart';
import './add-dashboard-dialog.dart';


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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard online demo',
      home: const MainPage(),
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

class _MainPageState extends State<MainPage> {
  // main page description

  Future<void> _addDashboard(BuildContext context) async {
    // opens dialog and adds a Dashboard to the menu
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const AddDashboardDialog();
        }
    );

    if (res != null && res != '') {
      setState(() {
        var newId = Random().nextInt(100000) + 4;
        menuItems.add(
            MenuItemData(
                name: res,
                id: newId
            )
        );
      });
    }
  }

  void _removeDashboard(id){
    // removes given dashboard from page
    if (menuItems.length <= 1){
      editingMode = false;
    }
    setState(() {
      menuItems.removeWhere((item) => item.id == id);
    });
  }

  void _placeholderFc(){
    // does nothing - placeholder
  }

  var editingMode = false;                      // sets the menu to editing mode
  var menuItems = <MenuItemData>[];             // array of menu items
  final _gridViewKey = GlobalKey();             // key for reorderable grid
  final _scrollController = ScrollController(); // scroll controller for reorderable grid

  @override
  Widget build(BuildContext context) {

    var generatedMenuList = List.generate(
      // generating the menu content - list of dashboard panels
      menuItems.length, (index) =>
        Container(
          key: Key(menuItems.elementAt(index).id.toString()),
          child: GestureDetector(
              onTap: () {
                if(!editingMode){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardWidget(itemData: menuItems.elementAt(index))
                      )
                  );
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
                            title: Text(menuItems.elementAt(index).name),
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
                                  _removeDashboard(menuItems.elementAt(index).id);
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                  size: 20,
                                )
                            )
                        ),
                    ],
                  )
              )
          ),
        )
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main menu'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: _placeholderFc, // TODO - replace
              icon: const Icon(Icons.search)
          ),
          IconButton(
              onPressed: _placeholderFc, // TODO - replace
              icon: const Icon(Icons.sort)
          ),
          IconButton(
              onPressed: _placeholderFc, // TODO - replace
              icon: const Icon(Icons.more_vert)
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.black54
        ),
        child: ReorderableBuilder(
          children: generatedMenuList,
          enableLongPress: false,
          enableDraggable: editingMode,
          onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
            for (final orderUpdateEntity in orderUpdateEntities) {
              final menuItem = menuItems.removeAt(orderUpdateEntity.oldIndex);
                menuItems.insert(orderUpdateEntity.newIndex, menuItem);
            }
          },
          builder: (children) {
            return GridView(
              padding: const EdgeInsets.all(8),
              key: _gridViewKey,
              controller: _scrollController,
              children: children,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3/4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8
              ),
            );
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {_addDashboard(context);},
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
