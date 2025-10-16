class Subject {
  String id;
  String name;
  String code;
  int credits;
  String grade;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    required this.grade,
  });

  double getGradePoint() {
    switch (grade) {
      case 'A+':
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'credits': credits,
      'grade': grade,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      credits: json['credits'] as int,
      grade: json['grade'] as String,
    );
  }

  Subject copy() {
    return Subject(
      id: id,
      name: name,
      code: code,
      credits: credits,
      grade: grade,
    );
  }
}

class Semester {
  String id;
  String name;
  double weight;
  List<Subject> subjects;

  Semester({
    required this.id,
    required this.name,
    required this.weight,
    required this.subjects,
  });

  double calculateGPA() {
    if (subjects.isEmpty) return 0.0;

    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var subject in subjects) {
      totalPoints += subject.getGradePoint() * subject.credits;
      totalCredits += subject.credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      subjects: (json['subjects'] as List)
          .map((s) => Subject.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Semester copy() {
    return Semester(
      id: id,
      name: name,
      weight: weight,
      subjects: subjects.map((s) => s.copy()).toList(),
    );
  }
}

class Year {
  String id;
  String name;
  List<Semester> semesters;

  Year({
    required this.id,
    required this.name,
    required this.semesters,
  });

  double calculateYearlyGPA() {
    if (semesters.isEmpty) return 0.0;

    double totalWeight = semesters.fold(0.0, (sum, sem) => sum + sem.weight);
    
    if (totalWeight == 0) return 0.0;

    double weightedSum = 0.0;
    
    for (var semester in semesters) {
      double semesterGPA = semester.calculateGPA();
      weightedSum += semesterGPA * (semester.weight / totalWeight);
    }

    return weightedSum;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'semesters': semesters.map((s) => s.toJson()).toList(),
    };
  }

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      id: json['id'] as String,
      name: json['name'] as String,
      semesters: (json['semesters'] as List)
          .map((s) => Semester.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Year copy() {
    return Year(
      id: id,
      name: name,
      semesters: semesters.map((s) => s.copy()).toList(),
    );
  }
}