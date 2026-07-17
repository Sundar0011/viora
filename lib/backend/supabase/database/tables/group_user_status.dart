import '../database.dart';

class GroupUserStatusTable extends SupabaseTable<GroupUserStatusRow> {
  @override
  String get tableName => 'group_user_status';

  @override
  GroupUserStatusRow createRow(Map<String, dynamic> data) =>
      GroupUserStatusRow(data);
}

class GroupUserStatusRow extends SupabaseDataRow {
  GroupUserStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupUserStatusTable();

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

  bool? get isInvited => getField<bool>('is_invited');
  set isInvited(bool? value) => setField<bool>('is_invited', value);

  bool? get isApproved => getField<bool>('is_approved');
  set isApproved(bool? value) => setField<bool>('is_approved', value);

  bool? get isMember => getField<bool>('is_member');
  set isMember(bool? value) => setField<bool>('is_member', value);

  String? get invitedBy => getField<String>('invited_by');
  set invitedBy(String? value) => setField<String>('invited_by', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get requestedDate => getField<DateTime>('requested_date');
  set requestedDate(DateTime? value) =>
      setField<DateTime>('requested_date', value);

  DateTime? get invitedDate => getField<DateTime>('invited_date');
  set invitedDate(DateTime? value) => setField<DateTime>('invited_date', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);
}
