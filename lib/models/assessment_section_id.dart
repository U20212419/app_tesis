class AssessmentSectionId {
  final int assessmentId;
  final int sectionId;

  const AssessmentSectionId({
    required this.assessmentId,
    required this.sectionId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AssessmentSectionId &&
              runtimeType == other.runtimeType &&
              assessmentId == other.assessmentId &&
              sectionId == other.sectionId;

  @override
  int get hashCode => assessmentId.hashCode ^ sectionId.hashCode;
}
