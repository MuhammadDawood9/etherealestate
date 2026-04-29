class FilterCriteria {
  final String query;
  final double? minPrice;
  final double? maxPrice;
  final int? minBeds;
  final String? propertyType;

  // 1. ADD 'const' HERE
  const FilterCriteria({
    this.query = '',
    this.minPrice,
    this.maxPrice,
    this.minBeds,
    this.propertyType,
  });

  // 2. CHANGE GETTER TO 'static const'
  static const FilterCriteria defaults = FilterCriteria();

  // ALIASES: Keeping these as they are used in your logic
  // Note: if your UI expects String for bedrooms, you might need .toString()
  // or change the logic in the repo where you parse them.
  String? get type => propertyType;
  int? get bedrooms => minBeds;

  bool get isDefault =>
      query.isEmpty &&
          minPrice == null &&
          maxPrice == null &&
          minBeds == null &&
          propertyType == null;

  FilterCriteria copyWith({
    String? query,
    double? minPrice,
    double? maxPrice,
    int? minBeds,
    String? propertyType,
  }) {
    return FilterCriteria(
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minBeds: minBeds ?? this.minBeds,
      propertyType: propertyType ?? this.propertyType,
    );
  }
}