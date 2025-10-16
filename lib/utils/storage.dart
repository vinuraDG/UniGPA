import '../models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  factory StorageManager() => _instance;
  StorageManager._internal();

  static const String _yearsKey = 'gpa_years';
  List<Year> _years = [];
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromStorage();
  }

  // Load data from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      String? yearsJson = _prefs?.getString(_yearsKey);
      if (yearsJson != null && yearsJson.isNotEmpty) {
        List<dynamic> yearsList = json.decode(yearsJson);
        _years = yearsList.map((y) => Year.fromJson(y as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error loading data: $e');
      _years = [];
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      String yearsJson = json.encode(_years.map((y) => y.toJson()).toList());
      await _prefs?.setString(_yearsKey, yearsJson);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  List<Year> getYears() {
    return _years.map((year) => year.copy()).toList();
  }

  Year? getYear(String yearId) {
    try {
      return _years.firstWhere((year) => year.id == yearId).copy();
    } catch (e) {
      return null;
    }
  }

  Future<void> addYear(Year year) async {
    _years.add(year.copy());
    await _saveToStorage();
  }

  Future<void> updateYear(Year year) async {
    int index = _years.indexWhere((y) => y.id == year.id);
    if (index != -1) {
      _years[index] = year.copy();
      await _saveToStorage();
    }
  }

  Future<void> deleteYear(String yearId) async {
    _years.removeWhere((year) => year.id == yearId);
    await _saveToStorage();
  }

  Semester? getSemester(String yearId, String semesterId) {
    Year? year = getYear(yearId);
    if (year == null) return null;

    try {
      return year.semesters.firstWhere((sem) => sem.id == semesterId).copy();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSemester(String yearId, Semester semester) async {
    int yearIndex = _years.indexWhere((y) => y.id == yearId);
    if (yearIndex != -1) {
      int semesterIndex = _years[yearIndex].semesters.indexWhere((s) => s.id == semester.id);
      if (semesterIndex != -1) {
        _years[yearIndex].semesters[semesterIndex] = semester.copy();
        await _saveToStorage();
      }
    }
  }

  double calculateOverallGPA() {
    if (_years.isEmpty) return 0.0;

    List<Map<String, dynamic>> allSemesters = [];
    
    for (var year in _years) {
      for (var semester in year.semesters) {
        allSemesters.add({
          'semester': semester,
          'gpa': semester.calculateGPA(),
          'weight': semester.weight,
        });
      }
    }

    if (allSemesters.isEmpty) return 0.0;

    double totalWeight = allSemesters.fold(0.0, (sum, sem) => sum + sem['weight'] as double);
    
    if (totalWeight == 0) return 0.0;

    double weightedSum = 0.0;
    for (var semData in allSemesters) {
      weightedSum += (semData['gpa'] as double) * (semData['weight'] as double);
    }

    return weightedSum / totalWeight;
  }

  List<Subject> getAllSubjects() {
    List<Subject> allSubjects = [];
    for (var year in _years) {
      for (var semester in year.semesters) {
        allSubjects.addAll(semester.subjects.map((s) => s.copy()));
      }
    }
    return allSubjects;
  }

  Future<void> clearAll() async {
    _years.clear();
    await _saveToStorage();
  }

  int getTotalSubjects() {
    int count = 0;
    for (var year in _years) {
      for (var semester in year.semesters) {
        count += semester.subjects.length;
      }
    }
    return count;
  }

  int getTotalCredits() {
    int credits = 0;
    for (var year in _years) {
      for (var semester in year.semesters) {
        for (var subject in semester.subjects) {
          credits += subject.credits;
        }
      }
    }
    return credits;
  }
}