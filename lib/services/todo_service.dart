import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo.dart';

class TodoService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TodoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<Todo>> getTodos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Todo.fromDocument(doc)).toList());
  }

  Future<void> addTodo(
    String title,
    String description, {
    DateTime? dueDate,
    required String category, // ← Tambahan
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    await _firestore.collection('todos').add(
      Todo(
        id: '',
        title: title,
        description: description,
        dueDate: dueDate,
        category: category, // ← Tambahan
        userId: userId,
      ).toMap(),
    );
  }

  Future<void> toggleTodo(Todo todo) async {
    await _firestore
        .collection('todos')
        .doc(todo.id)
        .update({'isDone': !todo.isDone});
  }

  Future<void> updateTodo(
    Todo todo,
    String title,
    String description, {
    DateTime? dueDate,
    String? category, // ← Optional jika kamu ingin bisa ubah juga kategori
  }) async {
    final data = {
      'title': title,
      'description': description,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      if (category != null) 'category': category, // ← Tambahan jika ada
    };
    await _firestore.collection('todos').doc(todo.id).update(data);
  }

  Future<void> deleteTodo(String todoId) async {
    await _firestore.collection('todos').doc(todoId).delete();
  }
}
