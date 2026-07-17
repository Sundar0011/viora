import '../database.dart';

class SearchHistoryTable extends SupabaseTable<SearchHistoryRow> {
  @override
  String get tableName => 'search_history';

  @override
  SearchHistoryRow createRow(Map<String, dynamic> data) =>
      SearchHistoryRow(data);
}

class SearchHistoryRow extends SupabaseDataRow {
  SearchHistoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SearchHistoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get search => getField<String>('search')!;
  set search(String value) => setField<String>('search', value);

  String get searchedBy => getField<String>('searched_by')!;
  set searchedBy(String value) => setField<String>('searched_by', value);

  DateTime? get lastUpdatedDate => getField<DateTime>('last_updated_date');
  set lastUpdatedDate(DateTime? value) =>
      setField<DateTime>('last_updated_date', value);
}
