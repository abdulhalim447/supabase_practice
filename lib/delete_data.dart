import 'package:flutter/material.dart';
import 'package:supabase_practice/services/student_service.dart';

class DeleteData extends StatefulWidget {
  const DeleteData({super.key});

  @override
  State<DeleteData> createState() => _DeleteDataState();
}

class _DeleteDataState extends State<DeleteData> {
  final List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  final StudentService _studentService = StudentService();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Students'),
        backgroundColor: Colors.red,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStudentList(),
    );
  }

  Widget _buildStudentList() {
    if (_students.isEmpty) {
      return const Center(
        child: Text('No students found', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: _students.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          student['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Age: ${student['age']}, Salary: \$${student['salary']}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(student),
        ),
      ),
    );
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _studentService.getAllStudents();
      setState(() {
        _students.clear();
        _students.addAll(students);
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error loading students: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(Map<String, dynamic> student) async {
    try {
      setState(() => _isLoading = true);

      await _studentService.deleteStudent(student['id']);

      // Refresh the list after successful deletion
      await _loadStudents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error deleting student: $e');
    }
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> student) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete ${student['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (shouldDelete == true && mounted) {
      await _deleteStudent(student);
    }
  }

  void _showError(String message) {
    debugPrint(message);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
