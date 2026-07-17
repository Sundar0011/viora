import '../database.dart';

class GroupMembersTable extends SupabaseTable<GroupMembersRow> {
  @override
  String get tableName => 'group_members';

  @override
  GroupMembersRow createRow(Map<String, dynamic> data) => GroupMembersRow(data);
}

class GroupMembersRow extends SupabaseDataRow {
  GroupMembersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupMembersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get groupId => getField<String>('group_id')!;
  set groupId(String value) => setField<String>('group_id', value);

  bool? get isRequested => getField<bool>('is_requested');
  set isRequested(bool? value) => setField<bool>('is_requested', value);

  DateTime? get requestedDate => getField<DateTime>('requested_date');
  set requestedDate(DateTime? value) =>
      setField<DateTime>('requested_date', value);

  bool? get isApproved => getField<bool>('is_approved');
  set isApproved(bool? value) => setField<bool>('is_approved', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);
}
