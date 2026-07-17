import '../database.dart';

class BlocksTable extends SupabaseTable<BlocksRow> {
  @override
  String get tableName => 'blocks';

  @override
  BlocksRow createRow(Map<String, dynamic> data) => BlocksRow(data);
}

class BlocksRow extends SupabaseDataRow {
  BlocksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BlocksTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get blockerId => getField<String>('blocker_id')!;
  set blockerId(String value) => setField<String>('blocker_id', value);

  String get blockedId => getField<String>('blocked_id')!;
  set blockedId(String value) => setField<String>('blocked_id', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);
}
