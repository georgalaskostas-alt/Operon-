import 'package:flutter/material.dart';
import 'data/app_store.dart';
import 'screens/dashboard_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/logbook_screen.dart';
import 'screens/workspace_screen.dart';
import 'theme/operon_theme.dart';

void main()=>runApp(const OperonApp());

class OperonApp extends StatefulWidget {
  const OperonApp({super.key});
  @override State<OperonApp> createState()=>_OperonAppState();
}
class _OperonAppState extends State<OperonApp> {
  final store=AppStore();
  @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'OPERON',theme:OperonTheme.dark(),home:AnimatedBuilder(animation:store,builder:(_,__)=>Shell(store:store)));
}

class Shell extends StatefulWidget {
  final AppStore store;
  const Shell({super.key,required this.store});
  @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell> {
  int index=0;
  @override Widget build(BuildContext context){
    final pages=[DashboardScreen(store:widget.store),EquipmentScreen(store:widget.store),LogbookScreen(store:widget.store),WorkspaceScreen(store:widget.store)];
    return Scaffold(
      body:SafeArea(child:IndexedStack(index:index,children:pages)),
      floatingActionButton:FloatingActionButton(onPressed:()=>_quick(context),child:const Icon(Icons.add_rounded,size:30)),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:NavigationBar(selectedIndex:index,onDestinationSelected:(v)=>setState(()=>index=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_rounded),label:'Home'),
        NavigationDestination(icon:Icon(Icons.precision_manufacturing_rounded),label:'Equipment'),
        NavigationDestination(icon:Icon(Icons.menu_book_rounded),label:'Logbook'),
        NavigationDestination(icon:Icon(Icons.grid_view_rounded),label:'More'),
      ]),
    );
  }

  void _quick(BuildContext context){
    final c=TextEditingController();
    showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,builder:(context)=>Padding(
      padding:EdgeInsets.fromLTRB(20,0,20,MediaQuery.viewInsetsOf(context).bottom+28),
      child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('Quick entry',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800)),
        const SizedBox(height:6),const Text('Write only what happened. Time and source are automatic.',style:TextStyle(color:OperonTheme.muted)),
        const SizedBox(height:16),TextField(controller:c,autofocus:true,maxLines:3,decoration:const InputDecoration(hintText:'e.g. P-2101A seal leak, maintenance informed')),
        const SizedBox(height:12),
        Row(children:[
          Expanded(child:OutlinedButton.icon(onPressed:(){},icon:const Icon(Icons.document_scanner),label:const Text('Scan notes'))),
          const SizedBox(width:10),
          Expanded(child:FilledButton.icon(onPressed:(){widget.store.addLog(c.text);Navigator.pop(context);},icon:const Icon(Icons.check),label:const Text('Save'))),
        ]),
      ]),
    ));
  }
}
