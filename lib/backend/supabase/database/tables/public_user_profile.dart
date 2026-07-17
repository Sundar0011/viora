import '../database.dart';

class PublicUserProfileTable extends SupabaseTable<PublicUserProfileRow> {
  @override
  String get tableName => 'public_user_profile';

  @override
  PublicUserProfileRow createRow(Map<String, dynamic> data) =>
      PublicUserProfileRow(data);
}

class PublicUserProfileRow extends SupabaseDataRow {
  PublicUserProfileRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PublicUserProfileTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get profilePicture => getField<String>('profile_picture');
  set profilePicture(String? value) =>
      setField<String>('profile_picture', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  DateTime? get lastSeenDate => getField<DateTime>('last_seen_date');
  set lastSeenDate(DateTime? value) =>
      setField<DateTime>('last_seen_date', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  int get followers => getField<int>('followers')!;
  set followers(int value) => setField<int>('followers', value);

  int get following => getField<int>('following')!;
  set following(int value) => setField<int>('following', value);

  PostgresTime? get logoutTime => getField<PostgresTime>('logout_time');
  set logoutTime(PostgresTime? value) =>
      setField<PostgresTime>('logout_time', value);

  String? get coverImage => getField<String>('cover_image');
  set coverImage(String? value) => setField<String>('cover_image', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get pronouns => getField<String>('pronouns');
  set pronouns(String? value) => setField<String>('pronouns', value);

  int get postCount => getField<int>('post_count')!;
  set postCount(int value) => setField<int>('post_count', value);

  int get groupCount => getField<int>('group_count')!;
  set groupCount(int value) => setField<int>('group_count', value);

  int get eventCount => getField<int>('event_count')!;
  set eventCount(int value) => setField<int>('event_count', value);

  int get saleCount => getField<int>('sale_count')!;
  set saleCount(int value) => setField<int>('sale_count', value);
}
