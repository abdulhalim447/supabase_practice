import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_practice/model/students.dart';

class StudentService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all students
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final response = await _client
        .from('students')
        .select()
        .order('id', ascending: true);

    return (response as List).map((item) {
      final data = Students.fromJson(item);
      return {
        'id': data.id,
        'name': data.name,
        'age': data.age,
        'salary': data.salary,
      };
    }).toList();
  }

  // Update a student
  Future<void> updateStudent(int id, Map<String, dynamic> data) async {
    // Convert salary to integer if it's a double
    final salary =
        data['salary'] is double
            ? (data['salary'] as double).toInt()
            : data['salary'];

    await _client
        .from('students')
        .update({
          'name': data['name'],
          'age': data['age'],
          'salary': salary, // Using the converted salary
        })
        .eq('id', id);
  }

  // Delete a student
  Future<void> deleteStudent(int id) async {
    await _client.from('students').delete().eq('id', id);
  }

  // Add a student
  Future<void> addStudent(Students student) async {
    await _client.from('students').insert(student.toJson());
  }

  // Get students with pagination
  Future<List<Map<String, dynamic>>> getStudentsWithPagination(
    int page,
    int limit,
  ) async {
    final response = await _client
        .from('students')
        .select()
        .order('id', ascending: true)
        .range(page * limit, (page + 1) * limit - 1);

    return (response as List).map((item) {
      final data = Students.fromJson(item);
      return {
        'id': data.id,
        'name': data.name,
        'age': data.age,
        'salary': data.salary,
      };
    }).toList();
  }
}
