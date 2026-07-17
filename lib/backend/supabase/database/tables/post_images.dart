import '../database.dart';

class PostImagesTable extends SupabaseTable<PostImagesRow> {
  @override
  String get tableName => 'post_images';

  @override
  PostImagesRow createRow(Map<String, dynamic> data) => PostImagesRow(data);
}

class PostImagesRow extends SupabaseDataRow {
  PostImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PostImagesTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get postId => getField<String>('post_id')!;
  set postId(String value) => setField<String>('post_id', value);

  String get image => getField<String>('image')!;
  set image(String value) => setField<String>('image', value);

  String get eMediaType => getField<String>('e_media_type')!;
  set eMediaType(String value) => setField<String>('e_media_type', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);
}
