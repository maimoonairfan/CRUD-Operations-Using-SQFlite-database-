import 'package:application/db_handler.dart';
import 'package:application/employeeModel.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DBHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.deepPurple,
        title: Text('Employee Data',style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<List<Employee>>(
        future: getAllEmployees(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No employees found'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Employee employee = snapshot.data![index];
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.designation),
                onTap: () {
                  _showUpdateDeleteEmployeeDialog(employee);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEmployeeDialog();
        },
        tooltip: 'Add Employee',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Designation'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age'),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addEmployee();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDeleteEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Employee Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${employee.name}'),
              Text('Title: ${employee.title}'),
              Text('Description: ${employee.description}'),
              Text('Designation: ${employee.designation}'),
              Text('Age: ${employee.age}'),
              Text('Email: ${employee.email}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _showEditEmployeeDialog(employee);
                Navigator.of(context).pop();
              },
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _deleteEmployee(employee);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

 void _showEditEmployeeDialog(Employee employee) {
  TextEditingController editNameController = TextEditingController(text: employee.name);
  TextEditingController editTitleController = TextEditingController(text: employee.title);
  TextEditingController editDescriptionController = TextEditingController(text: employee.description);
  TextEditingController editDesignationController = TextEditingController(text: employee.designation);
  TextEditingController editAgeController = TextEditingController(text: employee.age.toString());
  TextEditingController editEmailController = TextEditingController(text: employee.email);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Employee'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: editNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: editTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: editDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: editDesignationController,
                decoration: InputDecoration(labelText: 'Designation'),
              ),
              TextField(
                controller: editAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: editEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateEmployee(employee, editNameController.text, editTitleController.text,
                  editDescriptionController.text, editDesignationController.text,
                  int.parse(editAgeController.text), editEmailController.text);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

void _updateEmployee(Employee employee, String newName, String newTitle, String newDescription,
    String newDesignation, int newAge, String newEmail) async {
  final db = await dbHelper.database;
  Employee updatedEmployee = Employee(
    id: employee.id,
    name: newName,
    title: newTitle,
    description: newDescription,
    designation: newDesignation,
    age: newAge,
    email: newEmail,
  );
  await db.update(
    'employees',
    updatedEmployee.toMap(),
    where: 'id = ?',
    whereArgs: [updatedEmployee.id],
  );
  setState(() {
    // render the change on UI
  });
}
  void _addEmployee() async {
    final db = await dbHelper.database;
    Employee newEmployee = Employee(
      name: nameController.text,
      title: titleController.text,
      description: descriptionController.text,
      designation: designationController.text,
      age: int.parse(ageController.text),
      email: emailController.text,
    );
    await db.insert('employees', newEmployee.toMap());
    setState(() {
      // Refresh the UI
    });
  }

  void _deleteEmployee(Employee employee) async {
    final db = await dbHelper.database;
    await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employee.id],
    );
    setState(() {
      // Refresh the UI
    });
  }
  
}

