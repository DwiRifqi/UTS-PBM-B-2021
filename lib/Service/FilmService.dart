import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/film.dart';

class FilmService {
  final CollectionReference _filmRef =
      FirebaseFirestore.instance.collection('films');

  Future<void> addFilm(Film film) async {
    await _filmRef.add(film.toMap());
  }

  Future<void> updateFilm(Film film) async {
    await _filmRef.doc(film.id).update(film.toMap());
  }

  Future<void> deleteFilm(String id) async {
    await _filmRef.doc(id).delete();
  }

  Stream<List<Film>> getFilms() {
    return _filmRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Film.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}