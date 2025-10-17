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
          _showSnackbar('Subject added successfully');
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
            _showSnackbar('Subject updated successfully');
          }
        },
      ),
    );
  }

  void _deleteSubject(String subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Remove this subject from your semester?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentSemester.subjects.removeWhere((s) => s.id == subjectId);
                storage.updateSemester(widget.year.id, currentSemester);
                _loadData();
              });
              Navigator.pop(context);
              _showSnackbar('Subject deleted', isError: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double gpa = currentSemester.calculateGPA();
    int totalCredits = currentSemester.subjects.fold(0, (sum, s) => sum + s.credits);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          '${widget.year.name}, ${widget.semester.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/30848f96b8d6b9377f60438749a622c8.jpg', 
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.25),
          ),
          currentSemester.subjects.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.note_add_outlined,
                            size: 60,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Subjects Yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add your first subject to start tracking grades and GPA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildGPAHeader(gpa, totalCredits),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGPAHeader(double gpa, int totalCredits) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('GPA', gpa.toStringAsFixed(2)),
              _buildStatItem('Subjects', '${currentSemester.subjects.length}'),
              _buildStatItem('Credits', '$totalCredits'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    final upper = code.toUpperCase();
    if (upper.contains('CS')) return '💻';
    if (upper.contains('MATH')) return '📐';
    if (upper.contains('PSY')) return '🧠';
    if (upper.contains('PHY')) return '⚡';
    if (upper.contains('CHEM')) return '🧪';
    if (upper.contains('BIO')) return '🧬';
    if (upper.contains('ENG')) return '📝';
    if (upper.contains('HIST')) return '📜';
    if (upper.contains('ART')) return '🎨';
    if (upper.contains('MUS')) return '🎵';
    return '📚';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.blue;
      case 'B':
      case 'B-':
        return Colors.cyan;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'C-':
      case 'D+':
        return Colors.deepOrange;
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF42A5F5),
                      const Color(0xFF1976D2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getSubjectIcon(subject.code),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subject.code,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${subject.credits}c',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getGradeColor(subject.grade).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getGradeColor(subject.grade),
                    width: 2,
                  ),
                ),
                child: Text(
                  subject.grade,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(subject.grade),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                    onTap: onEdit,
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: const [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
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
      elevation: 8,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject == null ? 'Add Subject' : 'Edit Subject',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subject == null
                      ? 'Add a new subject to track your grade'
                      : 'Update subject information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g., Introduction to Programming',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.subject),
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
                  decoration: InputDecoration(
                    labelText: 'Subject Code',
                    hintText: 'e.g., CS101',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.code),
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
                  decoration: InputDecoration(
                    labelText: 'Credits',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.grade),
                  ),
                  items: [1, 2, 3].map((credit) {
                    return DropdownMenuItem(
                      value: credit,
                      child: Text('$credit Credit${credit > 1 ? 's' : ''}'),
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
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.star),
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
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.subject == null ? 'Add Subject' : 'Update Subject'),
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