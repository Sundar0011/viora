import '../database.dart';

class PostTable extends SupabaseTable<PostRow> {
  @override
  String get tableName => 'post';

  @override
  PostRow createRow(Map<String, dynamic> data) => PostRow(data);
}

class PostRow extends SupabaseDataRow {
  PostRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PostTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  int? get likesCount => getField<int>('likes_count');
  set likesCount(int? value) => setField<int>('likes_count', value);

  int? get commentCount => getField<int>('comment_count');
  set commentCount(int? value) => setField<int>('comment_count', value);

  int? get shareCount => getField<int>('share_count');
  set shareCount(int? value) => setField<int>('share_count', value);

  bool? get isEdited => getField<bool>('is_edited');
  set isEdited(bool? value) => setField<bool>('is_edited', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  DateTime? get lastModifiedDate => getField<DateTime>('last_modified_date');
  set lastModifiedDate(DateTime? value) =>
      setField<DateTime>('last_modified_date', value);

  int get seePostAccessId => getField<int>('see_post_access_id')!;
  set seePostAccessId(int value) => setField<int>('see_post_access_id', value);

  int get commentPostAccessId => getField<int>('comment_post_access_id')!;
  set commentPostAccessId(int value) =>
      setField<int>('comment_post_access_id', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  bool? get isGroupPost => getField<bool>('is_group_post');
  set isGroupPost(bool? value) => setField<bool>('is_group_post', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String get postStatus => getField<String>('post_status')!;
  set postStatus(String value) => setField<String>('post_status', value);

  List<dynamic> get taggedPeople => getListField<dynamic>('tagged_people');
  set taggedPeople(List<dynamic>? value) =>
      setListField<dynamic>('tagged_people', value);

  String? get contentText => getField<String>('content_text');
  set contentText(String? value) => setField<String>('content_text', value);

  String? get tldr => getField<String>('tldr');
  set tldr(String? value) => setField<String>('tldr', value);
}
