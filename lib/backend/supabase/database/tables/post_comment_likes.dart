import '../database.dart';

class PostCommentLikesTable extends SupabaseTable<PostCommentLikesRow> {
  @override
  String get tableName => 'post_comment_likes';

  @override
  PostCommentLikesRow createRow(Map<String, dynamic> data) =>
      PostCommentLikesRow(data);
}

class PostCommentLikesRow extends SupabaseDataRow {
  PostCommentLikesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PostCommentLikesTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get postId => getField<String>('post_id')!;
  set postId(String value) => setField<String>('post_id', value);

  String get commentId => getField<String>('comment_id')!;
  set commentId(String value) => setField<String>('comment_id', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);
}
