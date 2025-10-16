import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/storage.dart';
import '../utils/theme.dart';
import 'semester_subjects_page.dart';
import 'gpa_breakdown_page.dart';

class YearsSemestersPage extends StatefulWidget {
  const YearsSemestersPage({Key? key}) : super(key: key);

  @override
  State<YearsSemestersPage> createState() => _YearsSemestersPageState();
}

class _YearsSemestersPageState extends State<YearsSemestersPage> {
  final StorageManager storage = StorageManager();
  List<Year> years = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      years = storage.getYears();
    });
  }

  void _addYear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a new academic year to your program'),
            const SizedBox(height: 16),
            Text(
              'Year ${years.length + 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Year newYear = Year(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'Year ${years.length + 1}',
                semesters: [],
              );
              storage.addYear(newYear);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteYear(String yearId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Year'),
        content: const Text(
          'Are you sure you want to delete this year and all its data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              storage.deleteYear(yearId);
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addSemester(Year year) {
    showDialog(
      context: context,
      builder: (context) => _AddSemesterDialog(
        year: year,
        onAdd: (semester) {
          year.semesters.add(semester);
          storage.updateYear(year);
          _loadData();
        },
      ),
    );
  }

  void _deleteSemester(Year year, String semesterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester'),
        content: const Text(
          'Are you sure you want to delete this semester and all its subjects?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              year.semesters.removeWhere((s) => s.id == semesterId);
              storage.updateYear(year);
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('UniGPA',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
        centerTitle: true,
      ),
      body:
       Stack(
      fit: StackFit.expand,
      children: [
      
        Image.asset(
          'assets/images/30848f96b8d6b9377f60438749a622c8.jpg', 
          fit: BoxFit.cover,
        ),
       _selectedIndex == 0 ? _buildYearsPage() : const GPABreakdownPage(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            
            icon: Icon(Icons.school),
            label: 'Years & Semesters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'GPA Breakdown',
          ),
          
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _addYear,
              icon: const Icon(Icons.add),
              label: const Text('Add Year'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildYearsPage() {
    if (years.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 100,
              color: AppTheme.lightBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No years added yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first year',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: years.length,
      itemBuilder: (context, index) {
        return _YearCard(
          year: years[index],
          onAddSemester: () => _addSemester(years[index]),
          onDeleteYear: () => _deleteYear(years[index].id),
          onDeleteSemester: (semesterId) =>
              _deleteSemester(years[index], semesterId),
          onSemesterTap: (semester) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SemesterSubjectsPage(
                  year: years[index],
                  semester: semester,
                ),
              ),
            ).then((_) => _loadData());
          },
        );
      },
    );
  }
}

class _YearCard extends StatefulWidget {
  final Year year;
  final VoidCallback onAddSemester;
  final VoidCallback onDeleteYear;
  final Function(String) onDeleteSemester;
  final Function(Semester) onSemesterTap;

  const _YearCard({
    required this.year,
    required this.onAddSemester,
    required this.onDeleteYear,
    required this.onDeleteSemester,
    required this.onSemesterTap,
  });

  @override
  State<_YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<_YearCard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    double yearGPA = widget.year.calculateYearlyGPA();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.year.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: widget.year.semesters.isNotEmpty
                ? Text(
                    'GPA: ${yearGPA.toStringAsFixed(2)} • ${widget.year.semesters.length} Semester(s)',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const Text('No semesters added'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDeleteYear,
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.year.semesters.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No semesters yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...widget.year.semesters.map((semester) {
                      return _SemesterTile(
                        semester: semester,
                        onTap: () => widget.onSemesterTap(semester),
                        onDelete: () => widget.onDeleteSemester(semester.id),
                      );
                    }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddSemester,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Semester'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SemesterTile extends StatelessWidget {
  final Semester semester;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SemesterTile({
    required this.semester,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double gpa = semester.calculateGPA();

    return Card(
      color: AppTheme.backgroundColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accentBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.book,
            color: Colors.white,
          ),
        ),
        title: Text(
          semester.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          semester.subjects.isEmpty
              ? 'No subjects added'
              : 'GPA: ${gpa.toStringAsFixed(2)} • ${semester.subjects.length} Subject(s)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _AddSemesterDialog extends StatefulWidget {
  final Year year;
  final Function(Semester) onAdd;

  const _AddSemesterDialog({
    required this.year,
    required this.onAdd,
  });

  @override
  State<_AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<_AddSemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  double weight = 50.0;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: 'Semester ${widget.year.semesters.length + 1}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Semester',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Semester Name',
                  hintText: 'e.g., Semester 1',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter semester name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Weight: ${weight.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 16),
              ),
              Slider(
                value: weight,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${weight.toStringAsFixed(0)}%',
                onChanged: (value) {
                  setState(() {
                    weight = value;
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
                        Semester semester = Semester(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          weight: weight,
                          subjects: [],
                        );
                        widget.onAdd(semester);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}