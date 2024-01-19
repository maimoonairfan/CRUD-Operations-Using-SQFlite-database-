class Employee {
  int? id;
  String name;
  String title;
  String description;
  String designation;
  int age;
  String email;

  Employee({
    this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.designation,
    required this.age,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'designation': designation,
      'age': age,
      'email': email,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      title: map['title'],
      description: map['description'],
      designation: map['designation'],
      age: map['age'],
      email: map['email'],
    );
  }
}



