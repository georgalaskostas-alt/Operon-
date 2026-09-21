import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppStore extends ChangeNotifier {
  final List<Equipment> equipment = [
    Equipment(tag:'P-2101A',name:'Process Pump A',area:'Unit',state:EquipmentState.maintenance,note:'Mechanical inspection pending'),
    Equipment(tag:'P-2101B',name:'Process Pump B',area:'Unit'),
    Equipment(tag:'E-2204',name:'Process Exchanger',area:'Unit',note:'Monitor ΔP'),
    Equipment(tag:'FV-2205',name:'Flow Control Valve',area:'Unit',note:'Operating watch item'),
  ];
  final List<LogEntry> logs = [
    LogEntry(id:'1',createdAt:DateTime.now().subtract(const Duration(minutes:30)),text:'P-2101A stopped',equipmentTag:'P-2101A'),
    LogEntry(id:'2',createdAt:DateTime.now().subtract(const Duration(minutes:28)),text:'P-2101B started',equipmentTag:'P-2101B'),
    LogEntry(id:'3',createdAt:DateTime.now().subtract(const Duration(minutes:22)),text:'Maintenance informed',equipmentTag:'P-2101A'),
  ];
  final List<WatchItem> watch = [
    WatchItem(id:'w1',title:'Maintenance',detail:'Mechanical inspection pending',equipmentTag:'P-2101A'),
    WatchItem(id:'w2',title:'Monitor ΔP',detail:'Shift watch item',equipmentTag:'E-2204'),
  ];
  final List<OperatorTask> tasks = [OperatorTask(id:'t1',title:'Follow up mechanical inspection',equipmentTag:'P-2101A')];
  final List<ProcedureItem> procedures = const [
    ProcedureItem('Pump changeover','Operations','Approved procedure required'),
    ProcedureItem('Equipment isolation','Safety','Official LOTO/PTW procedure required'),
    ProcedureItem('Shift handover','Operations','OPERON checklist'),
  ];

  void addLog(String text,{String? tag}){final clean=text.trim();if(clean.isEmpty)return;logs.insert(0,LogEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),createdAt:DateTime.now(),text:clean,equipmentTag:tag));notifyListeners();}
  void setEquipmentState(Equipment item,EquipmentState state){item.state=state;addLog('${item.tag} → ${state.name}',tag:item.tag);}
  void addWatch(String title,String detail,{String? tag}){watch.insert(0,WatchItem(id:DateTime.now().microsecondsSinceEpoch.toString(),title:title,detail:detail,equipmentTag:tag));notifyListeners();}
  void addTask(String title,{String? tag}){final clean=title.trim();if(clean.isEmpty)return;tasks.insert(0,OperatorTask(id:DateTime.now().microsecondsSinceEpoch.toString(),title:clean,equipmentTag:tag));addLog('Action created: $clean',tag:tag);}
  void setTaskState(OperatorTask task,ActionState state){task.state=state;addLog('Action ${task.title} → ${state.name}',tag:task.equipmentTag);}
  void completeTask(OperatorTask task){setTaskState(task,ActionState.completed);}
}
