class PropertyModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String beds;
  final String baths;
  final String sqft;
  final String category;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.beds,
    required this.baths,
    required this.sqft,
    this.category = 'House',
  });

  int get bedrooms => int.tryParse(beds) ?? 0;

  String get type => category;

  double get priceValue {
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'location': location,
    'price': price,
    'imageUrl': imageUrl,
    'beds': beds,
    'baths': baths,
    'sqft': sqft,
    'category': category,
  };

  factory PropertyModel.fromMap(Map<String, dynamic> map) => PropertyModel(
    id: map['id']?.toString() ?? '',
    title: map['title']?.toString() ?? '',
    location: map['location']?.toString() ?? '',
    price: map['price']?.toString() ?? '',
    imageUrl: map['imageUrl']?.toString() ?? '',
    beds: map['beds']?.toString() ?? '0',
    baths: map['baths']?.toString() ?? '0',
    sqft: map['sqft']?.toString() ?? '0',
    category: map['category']?.toString() ?? 'House',
  );

  factory PropertyModel.fromApiMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Ethereal Estate',
      location: map['location']?.toString() ?? 'Lahore, Pakistan',
      price: map['price']?.toString() ?? 'Price on Request',
      imageUrl: map['imageUrl']?.toString() ?? 'https://picsum.photos/seed/${map['id']}/600/400',
      beds: (map['beds'] ?? 0).toString(),
      baths: (map['baths'] ?? 0).toString(),
      sqft: (map['areaSqft'] ?? 0).toString(),
      category: map['type']?.toString() ?? 'House',
    );
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    String? imageUrl,
    String? beds,
    String? baths,
    String? sqft,
    String? category,
  }) =>
      PropertyModel(
        id: id ?? this.id,
        title: title ?? this.title,
        location: location ?? this.location,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        beds: beds ?? this.beds,
        baths: baths ?? this.baths,
        sqft: sqft ?? this.sqft,
        category: category ?? this.category,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PropertyModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PropertyModel(id: $id, title: $title, location: $location, '
          'price: $price, beds: $beds, baths: $baths, sqft: $sqft, '
          'category: $category)';
}