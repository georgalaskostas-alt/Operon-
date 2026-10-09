import 'package:flutter_test/flutter_test.dart';
import 'package:operon/models/models.dart';
import 'package:operon/services/note_interpreter.dart';

void main() {
  final interpreter = NoteInterpreter();

  test('exact full-token tag match', () {
    final drafts = interpreter.interpret(
      'P-2101A stopped',
      [Equipment(tag: 'P-2101A', name: 'Pump A', area: 'Unit')],
    );
    expect(drafts.single.tag, 'P-2101A');
    expect(drafts.single.tagConfidence, 1);
  });

  test('does not confuse letter O with digit zero', () {
    final drafts = interpreter.interpret(
      'PO-2101A stopped',
      [
        Equipment(tag: 'P0-2101A', name: 'Pump 0', area: 'Unit'),
        Equipment(tag: 'PO-2101A', name: 'Pump O', area: 'Unit'),
      ],
    );
    expect(drafts.single.tag, 'PO-2101A');
  });

  test('rejects ambiguous near-matches', () {
    final drafts = interpreter.interpret(
      'P-2101C stopped',
      [
        Equipment(tag: 'P-2101A', name: 'Pump A', area: 'Unit'),
        Equipment(tag: 'P-2101B', name: 'Pump B', area: 'Unit'),
      ],
    );
    expect(drafts.single.tag, isNull);
  });

  test('rejects equipment ID embedded inside a longer token', () {
    final drafts = interpreter.interpret(
      'XP-2101AX',
      [Equipment(tag: 'P-2101A', name: 'Pump A', area: 'Unit')],
    );
    expect(drafts.single.tag, isNull);
  });
}
