class Review {
  final String userId;
  final String comment;
  final double rating;
  final String productId; // Add a field to store the associated product ID

  Review({
    required this.userId,
    required this.comment,
    required this.rating,
    required this.productId,
  });

  // Add a method to convert the Review object into a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comment': comment,
      'productId': productId,
      'rating': rating// Include the productId in the map
      // Add other fields if needed
    };
  }

  // Add a constructor to create a Review object from a map
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'],
      comment: map['comment'],
      productId: map['productId'],
      rating: map['rating'] ?? 0.0,
    );
  }
}
