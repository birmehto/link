class ApiConstants {
  static const String baseUrl = 'https://openlibrary.org';

  // API Endpoints
  static const String searchBooks = '/search.json';
  static const String getWork = '/works/{id}.json';
  static const String getEditions = '/works/{id}/editions.json';
  static const String getAuthor = '/authors/{id}.json';
  static const String getSubjects = '/subjects/{subject}.json';

  // Cover URLs
  static const String coverUrl = 'https://covers.openlibrary.org/b';
  static String getCoverUrl(String type, String value, String size) =>
      '$coverUrl/$type/$value-$size.jpg';

  // Image sizes
  static const String smallSize = 'S';
  static const String mediumSize = 'M';
  static const String largeSize = 'L';

  // Query parameters
  static const String limitParam = 'limit';
  static const String offsetParam = 'offset';
  static const String fieldsParam = 'fields';

  // Default values
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
}
