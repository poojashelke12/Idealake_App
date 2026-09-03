/// Helper utility for building Sitefinity OData v4 query parameters
class ODataQueryBuilder {
  final Map<String, dynamic> _params = {};

  /// Set the number of records to return ($top)
  ODataQueryBuilder top(int top) {
    _params['\$top'] = top;
    return this;
  }

  /// Set the number of records to skip ($skip for pagination)
  ODataQueryBuilder skip(int skip) {
    _params['\$skip'] = skip;
    return this;
  }

  /// Set sorting order ($orderby=PublicationDate desc)
  ODataQueryBuilder orderBy(String field, {bool ascending = false}) {
    _params['\$orderby'] = '$field ${ascending ? 'asc' : 'desc'}';
    return this;
  }

  /// Set field selection ($select=Title,Summary,PublicationDate)
  ODataQueryBuilder select(List<String> fields) {
    _params['\$select'] = fields.join(',');
    return this;
  }

  /// Add custom filter query ($filter)
  ODataQueryBuilder filter(String filterExpression) {
    _params['\$filter'] = filterExpression;
    return this;
  }

  /// Filter published & non-expired items
  ODataQueryBuilder filterActiveOnly() {
    final now = DateTime.now().toUtc().toIso8601String();
    _params['\$filter'] = "(ExpiryDate eq null or ExpiryDate gt $now)";
    return this;
  }

  /// Filter by category or taxonomy tag
  ODataQueryBuilder filterByCategory(String category) {
    if (category.isNotEmpty && category.toLowerCase() != 'all') {
      _params['\$filter'] = "Category eq '$category'";
    }
    return this;
  }

  /// Build the query map to pass to Dio queryParameters
  Map<String, dynamic> build() {
    return Map<String, dynamic>.from(_params);
  }
}
