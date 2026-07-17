import '../database.dart';

class PostCommentTable extends SupabaseTable<PostCommentRow> {
  @override
  String get tableName => 'post_comment';

  @override
  PostCommentRow createRow(Map<String, dynamic> data) => PostCommentRow(data);
}

class PostCommentRow extends SupabaseDataRow {
  PostCommentRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PostCommentTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get postId => getField<String>('post_id')!;
  set postId(String value) => setField<String>('post_id', value);

  String get comment => getField<String>('comment')!;
  set comment(String value) => setField<String>('comment', value);

  int? get likesCount => getField<int>('likes_count');
  set likesCount(int? value) => setField<int>('likes_count', value);

  int? get repliesCount => getField<int>('replies_count');
  set repliesCount(int? value) => setField<int>('replies_count', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get parentCommentId => getField<String>('parent_comment_id');
  set parentCommentId(String? value) =>
      setField<String>('parent_comment_id', value);

  String? get tldr => getField<String>('tldr');
  set tldr(String? value) => setField<String>('tldr', value);
}
