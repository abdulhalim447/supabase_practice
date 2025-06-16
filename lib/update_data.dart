import 'package:flutter/material.dart';
import 'package:supabase_practice/services/student_service.dart';
import 'package:supabase_practice/widgets/student_form_dialog.dart';

class UpdateData extends StatefulWidget {
  const UpdateData({super.key});

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  final List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  final StudentService _studentService = StudentService();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Students'),
        backgroundColor: Colors.orange,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _students.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        student['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Age: ${student['age']}, Salary: \$${student['salary']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showUpdateDialog(student),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> fetchData() async {
    try {
      final students = await _studentService.getAllStudents();
      setState(() {
        _students.clear();
        _students.addAll(students);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // update data ----------------------------------------------------------------------------------------------
  Future<void> _updateStudent(
    Map<String, dynamic> updatedData,
    int studentId,
  ) async {
    setState(() => _isLoading = true);
    try {
      // Update the student using the service
      await _studentService.updateStudent(studentId, updatedData);

      // Refresh the data
      await fetchData();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error updating student: $e');
    }
  }

  Future<void> _showUpdateDialog(Map<String, dynamic> student) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StudentFormDialog(initialData: student),
    );

    if (result != null) {
      await _updateStudent(result, student['id']);
    }
  }
}
