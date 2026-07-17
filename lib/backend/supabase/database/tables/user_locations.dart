import '../database.dart';

class UserLocationsTable extends SupabaseTable<UserLocationsRow> {
  @override
  String get tableName => 'user_locations';

  @override
  UserLocationsRow createRow(Map<String, dynamic> data) =>
      UserLocationsRow(data);
}

class UserLocationsRow extends SupabaseDataRow {
  UserLocationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserLocationsTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get location => getField<String>('location')!;
  set location(String value) => setField<String>('location', value);

  String? get place => getField<String>('place');
  set place(String? value) => setField<String>('place', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);
}
