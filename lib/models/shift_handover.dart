class ShiftHandover {
  final DateTime createdAt; final String outgoingShift; final List<String> openItems; final List<String> maintenance; final List<String> watchItems; final String notes;
  const ShiftHandover({required this.createdAt,required this.outgoingShift,required this.openItems,required this.maintenance,required this.watchItems,this.notes=''});
}