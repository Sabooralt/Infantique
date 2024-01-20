class Category {
  final String title;
  final String image;

  Category({
    required this.title,
    required this.image,
  });
}

final List<Category> categories = [
  Category(title: "Feeding", image: "assets/feeding1.jpg"),
  Category(title: "Bath", image: "assets/bath1.jpg"),
  Category(title: "Safety", image: "assets/safety1.jpg"),
  Category(title: "Diapers", image: "assets/diaper1.jpg"),
  Category(title: "Toys", image: "assets/toys1.jpg"),
];
