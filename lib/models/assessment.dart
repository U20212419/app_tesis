class Assessment {
  final int id;
  final String type;
  final int number;
  int? questionAmount;
  final int idSemester;
  final int idCourse;

  Assessment({
    required this.id,
    required this.type,
    required this.number,
    this.questionAmount,
    required this.idSemester,
    required this.idCourse,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id_assessment'],
      type: json['type'],
      number: json['number'],
      questionAmount: json['question_amount'],
      idSemester: json['id_semester'],
      idCourse: json['id_course'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_assessment': id,
      'type': type,
      'number': number,
      'question_amount': questionAmount,
      'id_semester': idSemester,
      'id_course': idCourse,
    };
  }
}
