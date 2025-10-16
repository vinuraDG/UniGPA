import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/storage.dart';
import '../utils/theme.dart';

class SemesterSubjectsPage extends StatefulWidget {
  final Year year;
  final Semester semester;

  const SemesterSubjectsPage({
    Key? key,
    required this.year,
    required this.semester,
  }) : super(key: key);

  @override
  State<SemesterSubjectsPage> createState() => _SemesterSubjectsPageState();
}

class _SemesterSubjectsPageState extends State<SemesterSubjectsPage> {
  final StorageManager storage = StorageManager();
  late Semester currentSemester;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      currentSemester = storage.getSemester(widget.year.id, widget.semester.id) 
          ?? widget.semester;
    });
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => _AddSubjectDialog(
        onAdd: (subject) {
          currentSemester.subjects.add(subject);
          storage.updateSemester(widget.year.id, currentSemester);
          _loadData();
        },
      ),
    );
  }

  void _editSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => _AddSubjectDialog(
        subject: subject,
        onAdd: (updatedSubject) {
          int index = currentSemester.subjects.indexWhere((s) => s.id == subject.id);
          if (index != -1) {
            currentSemester.subjects[index] = updatedSubject;
            storage.updateSemester(widget.year.id, currentSemester);
            _loadData();
          }
        },
      ),
    );
  }

  void _deleteSubject(String subjectId) {
    setState(() {
      currentSemester.subjects.removeWhere((s) => s.id == subjectId);
      storage.updateSemester(widget.year.id, currentSemester);
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double gpa = currentSemester.calculateGPA();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year.name}, ${widget.semester.name}'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/30848f96b8d6b9377f60438749a622c8.jpg', 
            fit: BoxFit.cover,
          ),
          currentSemester.subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 100,
                        color: AppTheme.lightBlue.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No subjects added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first subject',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Semester GPA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gpa.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentSemester.subjects.length,
                        itemBuilder: (context, index) {
                          Subject subject = currentSemester.subjects[index];
                          return _SubjectCard(
                            subject: subject,
                            onEdit: () => _editSubject(subject),
                            onDelete: () => _deleteSubject(subject.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  String _getSubjectIcon(String code) {
    if (code.toUpperCase().contains('CS')) return '💻';
    if (code.toUpperCase().contains('MATH')) return '📐';
    if (code.toUpperCase().contains('PSY')) return '🧠';
    if (code.toUpperCase().contains('PHY')) return '⚡';
    if (code.toUpperCase().contains('CHEM')) return '🧪';
    if (code.toUpperCase().contains('BIO')) return '🧬';
    if (code.toUpperCase().contains('ENG')) return '📝';
    return '📚';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getSubjectIcon(subject.code),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.code} • ${subject.credits} Credits • Grade: ${subject.grade}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.accentBlue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSubjectDialog extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onAdd;

  const _AddSubjectDialog({
    this.subject,
    required this.onAdd,
  });

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController codeController;
  int credits = 3;
  String grade = 'A';

  final List<String> grades = [
    'A+', 'A', 'A-',
    'B+', 'B', 'B-',
    'C+', 'C', 'C-',
    'D+', 'D', 'F'
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.subject?.name ?? '');
    codeController = TextEditingController(text: widget.subject?.code ?? '');
    credits = widget.subject?.credits ?? 3;
    grade = widget.subject?.grade ?? 'A';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.subject == null ? 'Add Subject' : 'Edit Subject',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g., Introduction to Programming',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code',
                    hintText: 'e.g., CS101',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: credits,
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                  ),
                  items: [1, 2, 3, 4, 5, 6].map((credit) {
                    return DropdownMenuItem(
                      value: credit,
                      child: Text('$credit Credits'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      credits = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: grade,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                  ),
                  items: grades.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      grade = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Subject subject = Subject(
                            id: widget.subject?.id ?? 
                                DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameController.text,
                            code: codeController.text,
                            credits: credits,
                            grade: grade,
                          );
                          widget.onAdd(subject);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.subject == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }
}