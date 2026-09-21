class OperatorNote {
  final String id; final DateTime createdAt; final String title; final String body; final String? equipmentTag; final bool pinned;
  const OperatorNote({required this.id,required this.createdAt,required this.title,required this.body,this.equipmentTag,this.pinned=false});
}