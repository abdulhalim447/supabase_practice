import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_practice/model/students.dart';

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  int _currentPage = 0;
  int _limit = 5;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when widget initializes
  }

  final List<Map<String, dynamic>> _students = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fetch data')),
      body: Column(
        children: [
          Expanded(
            child:
                _students.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 3,
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              _students[index]['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Age: ${_students[index]['age']}, salary: \$${_students[index]['salary']}',
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed:
                  _isLoading || !_hasMoreData
                      ? null
                      : () {
                        setState(() {
                          _currentPage++; // Increment the page
                        });
                        fetchData(); // Fetch next page of data
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    Text(
                      _hasMoreData ? 'Load More' : 'No More Data',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _hasMoreData
                          ? Icons.arrow_downward
                          : Icons.check_circle_outline,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('students')
          .select()
          .order('id', ascending: true)
          .range(_currentPage * _limit, (_currentPage + 1) * _limit - 1);

      final newData =
          (response as List).map((item) {
            final data = Students.fromJson(item);
            return {'name': data.name, 'age': data.age, 'salary': data.salary};
          }).toList();

      setState(() {
        if (_currentPage == 0) {
          _students.clear();
        }
        _students.addAll(newData);
        _hasMoreData = newData.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
