import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/film.dart';
import '../service/filmservice.dart';

class FilmListPage extends StatefulWidget {
  const FilmListPage({super.key});

  @override
  State<FilmListPage> createState() => _FilmListPageState();
}

class _FilmListPageState extends State<FilmListPage> {
  final FilmService _filmService = FilmService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _rating = 3;

  Film? _editingFilm;

  void _submitFilm() {
    if (_formKey.currentState!.validate()) {
      final film = Film(
        id: _editingFilm?.id,
        title: _titleController.text,
        genre: _genreController.text,
        year: int.parse(_yearController.text),
        rating: _rating,
        description: _descriptionController.text,
      );

      if (_editingFilm == null) {
        _filmService.addFilm(film);
      } else {
        _filmService.updateFilm(film);
      }

      _clearFields();
    }
  }

  void _clearFields() {
    _titleController.clear();
    _genreController.clear();
    _yearController.clear();
    _descriptionController.clear();
    _rating = 3;
    setState(() => _editingFilm = null);
  }

  void _editFilm(Film film) {
    setState(() {
      _editingFilm = film;
      _titleController.text = film.title;
      _genreController.text = film.genre;
      _yearController.text = film.year.toString();
      _descriptionController.text = film.description;
      _rating = film.rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🎬 Koleksi Film'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 183, 206, 85),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Judul Film'),
                        validator: (val) => val!.isEmpty ? 'Wajib diisi!' : null,
                      ),
                      TextFormField(
                        controller: _genreController,
                        decoration: const InputDecoration(labelText: 'Genre'),
                      ),
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: 'Tahun Rilis'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Deskripsi'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Rating:"),
                          const SizedBox(width: 12),
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            maxRating: 5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 24,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: Icon(_editingFilm == null ? Icons.add : Icons.save, color: Colors.black),
                        label: Text(
                          _editingFilm == null ? 'Tambah Film' : 'Simpan Perubahan',
                          style: const TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 171, 212, 87),
                        ),
                        onPressed: _submitFilm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Film>>(
                stream: _filmService.getFilms(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final films = snapshot.data!;
                  if (films.isEmpty) return const Center(child: Text('Belum ada film'));

                  return ListView.builder(
                    itemCount: films.length,
                    itemBuilder: (context, index) {
                      final film = films[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      film.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${film.genre} • ${film.year}'),
                                    const SizedBox(height: 4),
                                    Text(film.description),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        if (index < film.rating.floor()) {
                                          return const Icon(Icons.star, color: Colors.amber, size: 20);
                                        } else if (index < film.rating && (film.rating - film.rating.floor()) >= 0.5 && index == film.rating.floor()) {
                                          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
                                        } else {
                                          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
                                        }
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editFilm(film),
                                  ),
                                  const SizedBox(height: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _filmService.deleteFilm(film.id!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
