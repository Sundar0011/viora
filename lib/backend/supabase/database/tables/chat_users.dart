import '../database.dart';

class ChatUsersTable extends SupabaseTable<ChatUsersRow> {
  @override
  String get tableName => 'chat_users';

  @override
  ChatUsersRow createRow(Map<String, dynamic> data) => ChatUsersRow(data);
}

class ChatUsersRow extends SupabaseDataRow {
  ChatUsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChatUsersTable();

  String get chatId => getField<String>('chat_id')!;
  set chatId(String value) => setField<String>('chat_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  DateTime? get deletedDate => getField<DateTime>('deleted_date');
  set deletedDate(DateTime? value) => setField<DateTime>('deleted_date', value);
}
