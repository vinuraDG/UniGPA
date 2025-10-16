import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/storage.dart';
import '../utils/theme.dart';

class GPABreakdownPage extends StatefulWidget {
  const GPABreakdownPage({Key? key}) : super(key: key);

  @override
  State<GPABreakdownPage> createState() => _GPABreakdownPageState();
}

class _GPABreakdownPageState extends State<GPABreakdownPage> {
  final StorageManager storage = StorageManager();
  List<Year> years = [];

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

  void _editWeight(Year year, Semester semester) {
    TextEditingController weightController = 
        TextEditingController(text: semester.weight.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Semester Weight'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (%)',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              double newWeight = double.tryParse(weightController.text) ?? 50.0;
              semester.weight = newWeight;
              storage.updateSemester(year.id, semester);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double overallGPA = storage.calculateOverallGPA();

    return Scaffold(
      
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🖼️ Background image
          Image.asset(
            'assets/images/30848f96b8d6b9377f60438749a622c8.jpg', // <-- add your image path
            fit: BoxFit.cover,
          ),

          // Foreground content
          years.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 100,
                        color: AppTheme.lightBlue.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add years and subjects to see your GPA breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Overall GPA Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Final Weighted GPA',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              overallGPA.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grade Scale Reference
                      _buildGradeScaleCard(),

                      // Years Breakdown
                      ...years.map((year) => _YearBreakdownCard(
                            year: year,
                            onEditWeight: (semester) => _editWeight(year, semester),
                            onRefresh: _loadData,
                          )),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Calculate GPA button - already calculated in real-time
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Current GPA: ${overallGPA.toStringAsFixed(2)}'),
              backgroundColor: AppTheme.primaryBlue,
            ),
          );
        },
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate GPA'),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGradeScaleCard() {
    final gradeScale = {
      'A+/A': '4.0',
      'A-': '3.7',
      'B+': '3.3',
      'B': '3.0',
      'B-': '2.7',
      'C+': '2.3',
      'C': '2.0',
      'C-': '1.7',
      'D+': '1.3',
      'D': '1.0',
      'F': '0.0',
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: const Text(
          '📊 Grade Scale Reference',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: gradeScale.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentBlue),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearBreakdownCard extends StatefulWidget {
  final Year year;
  final Function(Semester) onEditWeight;
  final VoidCallback onRefresh;

  const _YearBreakdownCard({
    required this.year,
    required this.onEditWeight,
    required this.onRefresh,
  });

  @override
  State<_YearBreakdownCard> createState() => _YearBreakdownCardState();
}

class _YearBreakdownCardState extends State<_YearBreakdownCard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    double yearGPA = widget.year.calculateYearlyGPA();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.year.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Yearly GPA: ${yearGPA.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            ...widget.year.semesters.map((semester) {
              return _SemesterBreakdownTile(
                semester: semester,
                onEditWeight: () => widget.onEditWeight(semester),
              );
            }),
        ],
      ),
    );
  }
}

class _SemesterBreakdownTile extends StatelessWidget {
  final Semester semester;
  final VoidCallback onEditWeight;

  const _SemesterBreakdownTile({
    required this.semester,
    required this.onEditWeight,
  });

  @override
  Widget build(BuildContext context) {
    double semesterGPA = semester.calculateGPA();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                semester.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Weight: ${semester.weight.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppTheme.accentBlue),
                    onPressed: onEditWeight,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semester GPA: ${semesterGPA.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...semester.subjects.map((subject) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      subject.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Grade: ${subject.grade}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    '${subject.credits} Credits',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}