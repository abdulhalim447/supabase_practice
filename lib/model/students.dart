class Students {
  final int? id; // Make id optional since it's auto-generated
  final String name;
  final int age;
  final int salary; // Changed to int to match the bigint in database

  Students({
    this.id, // Optional id
    required this.name,
    required this.age,
    required this.salary,
  });

  // Factory method to create a Students object from JSON
  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      id: json['id'] as int?,
      name: json['name'] as String,
      age: json['age'] as int,
      salary: (json['salary'] as num).toInt(), // Convert to int for bigint
    );
  }

  // Method to convert a Students object to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Only include id if it's not null
      'name': name,
      'age': age,
      'salary': salary,
    };
  }
}
