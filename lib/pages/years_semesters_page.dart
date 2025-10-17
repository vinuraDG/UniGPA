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
      builder: (context) => _CustomDialog(
        title: 'Add New Year',
        description: 'Start tracking your academics for Year ${years.length + 1}',
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Year ${years.length + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        onConfirm: () {
          Year newYear = Year(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Year ${years.length + 1}',
            semesters: [],
          );
          storage.addYear(newYear);
          Navigator.pop(context);
          _loadData();
          _showSnackbar('Year added successfully');
        },
      ),
    );
  }

  void _deleteYear(String yearId) {
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: 'Delete Year',
        description: 'This action cannot be undone. All semesters and subjects will be removed.',
        isDangerous: true,
        onConfirm: () {
          storage.deleteYear(yearId);
          Navigator.pop(context);
          _loadData();
          _showSnackbar('Year deleted', isError: true);
        },
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
          _showSnackbar('Semester added successfully');
        },
      ),
    );
  }

  void _deleteSemester(Year year, String semesterId) {
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: 'Delete Semester',
        description: 'Remove this semester and all its subjects?',
        isDangerous: true,
        onConfirm: () {
          year.semesters.removeWhere((s) => s.id == semesterId);
          storage.updateYear(year);
          Navigator.pop(context);
          _loadData();
          _showSnackbar('Semester deleted', isError: true);
        },
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
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text(
          'UniGPA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/30848f96b8d6b9377f60438749a622c8.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          _selectedIndex == 0 ? _buildYearsPage() : const GPABreakdownPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Year'),
              backgroundColor: Colors.blue[700],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildYearsPage() {
    if (years.isEmpty) {
      return Center(
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
                  Icons.school_outlined,
                  size: 60,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Years Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the + button below to add your first academic year',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: years.length,
      itemBuilder: (context, index) => _YearCard(
        year: years[index],
        onAddSemester: () => _addSemester(years[index]),
        onDeleteYear: () => _deleteYear(years[index].id),
        onDeleteSemester: (semesterId) => _deleteSemester(years[index], semesterId),
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
      ),
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

class _YearCardState extends State<_YearCard> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (isExpanded) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double yearGPA = widget.year.calculateYearlyGPA();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.year.name.replaceAll('Year ', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              widget.year.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: widget.year.semesters.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'GPA: ${yearGPA.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.year.semesters.length} Semester${widget.year.semesters.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    'No semesters yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDeleteYear,
                  tooltip: 'Delete year',
                ),
                IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.close_menu,
                    progress: _animationController,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      if (isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: isExpanded
                ? Column(
                    children: [
                      Divider(height: 1, color: Colors.grey[300]),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.year.semesters.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No semesters added',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: widget.year.semesters
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int idx = entry.key;
                                  Semester semester = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: idx < widget.year.semesters.length - 1 ? 12 : 0,
                                    ),
                                    child: _SemesterTile(
                                      semester: semester,
                                      onTap: () => widget.onSemesterTap(semester),
                                      onDelete: () => widget.onDeleteSemester(semester.id),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: widget.onAddSemester,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Semester'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.blue[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue[200]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'GPA: ${gpa.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          semester.subjects.isEmpty
                              ? 'No subjects'
                              : '${semester.subjects.length} Subject${semester.subjects.length > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
                tooltip: 'Delete semester',
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
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
                const Text(
                  'Add Semester',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new semester for ${widget.year.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Semester Name',
                    hintText: 'e.g., Semester 1, Fall 2024',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter semester name' : null,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Semester Weight',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${weight.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: weight,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${weight.toStringAsFixed(0)}%',
                      onChanged: (value) => setState(() => weight = value),
                      activeColor: Colors.blue[600],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          Text('100%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Semester'),
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
    super.dispose();
  }
}

class _CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? content;
  final bool isDangerous;
  final VoidCallback onConfirm;

  const _CustomDialog({
    required this.title,
    required this.description,
    this.content,
    this.isDangerous = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDangerous)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.red[700], size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Warning',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],
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
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDangerous ? Colors.red[600] : Colors.blue[700],
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isDangerous ? 'Delete' : 'Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}