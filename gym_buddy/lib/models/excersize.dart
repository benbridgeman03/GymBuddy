import 'bodypart.dart';

enum ExcersizeCategory{
  barbell,
  dumbell,
  machine,
  bodyweight,
  assisedBodyweight,
  cable,
  other
}

class Excersize  {
  final String name;
  final BodyPart bodyPart;
  final ExcersizeCategory category;
  final double personalBest;

  Excersize ({
    required this.name,
    required this.bodyPart,
    required this.category,
    required this.personalBest,
  });
}