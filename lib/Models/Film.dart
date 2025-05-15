class Film {
  String? id;
  String title;
  String genre;
  int year;
  double rating;
  String description;

  Film({
    this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.description,
  });

  factory Film.fromMap(Map<String, dynamic> data, String documentId) {
    return Film(
      id: documentId,
      title: data['title'],
      genre: data['genre'],
      year: data['year'],
      rating: (data['rating'] as num).toDouble(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'year': year,
      'rating': rating,
      'description': description,
    };
  }
}