class BookingModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String date;     // Expected format: YYYY-MM-DD
  final String timeSlot; // e.g., "11:00 AM"
  final String createdAt;
  final String status;   // 'pending', 'confirmed', 'canceled'

  const BookingModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.date,
    required this.timeSlot,
    required this.createdAt,
    this.status = 'pending', // Defaults to pending
  });

  // 1. copyWith: Mechanical necessity for Riverpod state updates
  BookingModel copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? date,
    String? timeSlot,
    String? createdAt,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  // 2. Serialization logic
  Map<String, dynamic> toMap() => {
    'id': id,
    'propertyId': propertyId,
    'propertyTitle': propertyTitle,
    'date': date,
    'timeSlot': timeSlot,
    'createdAt': createdAt,
    'status': status,
  };

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'] as String,
    propertyId: map['propertyId'] as String,
    propertyTitle: map['propertyTitle'] as String,
    date: map['date'] as String,
    timeSlot: map['timeSlot'] as String,
    createdAt: map['createdAt'] as String,
    status: map['status'] as String? ?? 'pending',
  );

  // 3. UI Helper: Converts "2026-04-28" to "28 Apr 2026"
  String get formattedDate {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[month]} ${parts[0]}';
  }

  // 4. Value Equality: Ensures Riverpod doesn't trigger unnecessary UI rebuilds
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookingModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;
}