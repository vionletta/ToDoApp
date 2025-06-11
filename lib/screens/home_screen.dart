import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/todo_service.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AuthService>();
    final todoService = context.read<TodoService>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Todo List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1a1a1a),
      body: StreamBuilder<List<Todo>>(
        stream: todoService.getTodos(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final todos = snap.data ?? [];
          if (todos.isEmpty) {
            return Center(
              child: Text(
                'Belum ada todo',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            );
          }

          final groups = _groupTodos(todos);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final g in groups) ...[
                Text(
                  g.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                const SizedBox(height: 8),
                for (var i = 0; i < g.items.length; i++)
                  TodoItem(
                    todo: g.items[i],
                    todoService: todoService,
                  ).animate().fadeIn(
                    duration: Duration(milliseconds: 300 + (i * 50)),
                  ),
                const SizedBox(height: 24),
              ]
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddTodoSheet(
          context,
          service: todoService,
        ),
      ),
    );
  }
}

class _TodoGroup {
  _TodoGroup(this.label, this.items);
  final String label;
  final List<Todo> items;
}

List<_TodoGroup> _groupTodos(List<Todo> todos) {
  DateTime strip(DateTime d) => DateTime(d.year, d.month, d.day);

  final map = <DateTime?, List<Todo>>{};
  for (final t in todos) {
    final key = t.dueDate == null ? null : strip(t.dueDate!);
    map.putIfAbsent(key, () => []).add(t);
  }

  final keys = map.keys.toList()
    ..sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });

  String labelFor(DateTime? d) {
    if (d == null) return 'Tanpa Tanggal';

    final today = strip(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));

    if (d == today) return 'Hari ini';
    if (d == tomorrow) return 'Besok';

    return DateFormat('dd/MM/yyyy').format(d);
  }

  return [
    for (final k in keys) _TodoGroup(labelFor(k), map[k]!)
  ];
}

Future<void> _showAddTodoSheet(
  BuildContext context, {
  required TodoService service,
}) async {
  final theme = Theme.of(context);
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? selectedDate;
  String selectedCategory = 'Pekerjaan';
  final List<String> categories = ['Pekerjaan', 'Pribadi', 'Belanja', 'Lain-lain'];

  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tambah Todo Baru',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Judul',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              textInputAction: TextInputAction.next,
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              maxLines: 3,
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              )).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
            ).animate().fadeIn(delay: const Duration(milliseconds: 325)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(
                selectedDate == null
                    ? 'Pilih tanggal…'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: selectedDate ?? now,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ).animate().fadeIn(delay: const Duration(milliseconds: 350)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    label: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx, {
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'dueDate': selectedDate,
                      'category': selectedCategory,
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (result != null && result['title']!.isNotEmpty) {
    await service.addTodo(
      result['title']!,
      result['description'] ?? '',
      dueDate: result['dueDate'] as DateTime?,
      category: result['category'] as String,
    );
  }
}
