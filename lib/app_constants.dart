// app_constants.dart
// App-wide display constants that are not user- or environment-configurable.
// Kept in one place so a change here updates every screen at once, instead of
// the same literal being repeated across widget files.

/// Currency symbol shown next to marketplace prices.
///
/// Viora/Flock launches in India, so prices are rupees. The FlutterFlow-generated
/// screens originally hardcoded '£' in six places, which rendered every listing
/// with the wrong currency.
const String kCurrencySymbol = '₹';
