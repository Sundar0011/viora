import '../database.dart';

class PostLikeTable extends SupabaseTable<PostLikeRow> {
  @override
  String get tableName => 'post_like';

  @override
  PostLikeRow createRow(Map<String, dynamic> data) => PostLikeRow(data);
}

class PostLikeRow extends SupabaseDataRow {
  PostLikeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PostLikeTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get postId => getField<String>('post_id')!;
  set postId(String value) => setField<String>('post_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);
}
