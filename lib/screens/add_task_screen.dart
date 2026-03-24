import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late String title;
  late String subject;
  late String dueDate;
  String priority = 'Low';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      title = widget.task!.title;
      subject = widget.task!.subject;
      dueDate = widget.task!.dueDate;
      priority = widget.task!.priority;
    } else {
      title = '';
      subject = '';
      dueDate = '';
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        dueDate = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: "Task Title",
                initialValue: title,
                onChanged: (val) => title = val,
              ),
              _buildTextField(
                label: "Subject",
                initialValue: subject,
                onChanged: (val) => subject = val,
              ),
              
              // Date picker
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_today, color: Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Due Date", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            dueDate.isEmpty ? "Not set" : dueDate,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: pickDate,
                      child: const Text("Select", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              // Priority Dropdown
              DropdownButtonFormField<String>(
                value: priority,
                dropdownColor: const Color(0xFF1E293B),
                items: ['Low', 'Medium', 'High']
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Priority",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (title.trim().isEmpty) return;

                  setState(() => _isLoading = true);

                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    final taskData = {
                      'userId': currentUser.uid,
                      'title': title,
                      'subject': subject,
                      'dueDate': dueDate,
                      'priority': priority,
                      'isCompleted': widget.task?.isCompleted ?? false,
                    };

                    try {
                      if (widget.task == null) {
                        await FirebaseFirestore.instance.collection('tasks').add(taskData);
                      } else {
                        await FirebaseFirestore.instance.collection('tasks').doc(widget.task!.id).update(taskData);
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        setState(() => _isLoading = false);
                      }
                    }
                  } else {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Save Task",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}