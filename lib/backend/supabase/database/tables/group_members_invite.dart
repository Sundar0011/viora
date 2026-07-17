import '../database.dart';

class GroupMembersInviteTable extends SupabaseTable<GroupMembersInviteRow> {
  @override
  String get tableName => 'group_members_invite';

  @override
  GroupMembersInviteRow createRow(Map<String, dynamic> data) =>
      GroupMembersInviteRow(data);
}

class GroupMembersInviteRow extends SupabaseDataRow {
  GroupMembersInviteRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupMembersInviteTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get invitedBy => getField<String>('invited_by')!;
  set invitedBy(String value) => setField<String>('invited_by', value);

  String get groupId => getField<String>('group_id')!;
  set groupId(String value) => setField<String>('group_id', value);

  String get invitedUser => getField<String>('invited_user')!;
  set invitedUser(String value) => setField<String>('invited_user', value);

  bool get isMember => getField<bool>('is_member')!;
  set isMember(bool value) => setField<bool>('is_member', value);

  DateTime? get acceptedAt => getField<DateTime>('accepted_at');
  set acceptedAt(DateTime? value) => setField<DateTime>('accepted_at', value);
}
