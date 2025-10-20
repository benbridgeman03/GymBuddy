import 'package:cloud_firestore/cloud_firestore.dart';
import 'bodypart.dart';

enum ExcersizeCategory {
  barbell,
  dumbell,
  machine,
  bodyweight,
  assisedBodyweight,
  cable,
  other,
}

class Exercise {
  final String id;
  final String name;
  final BodyPart bodyPart;
  final ExcersizeCategory category;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'bodyPart': bodyPart.name, 'category': category.name};
  }

  factory Exercise.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise(
      id: doc.id,
      name: data['name'],
      bodyPart: BodyPart.values.firstWhere((b) => b.name == data['bodyPart']),
      category: ExcersizeCategory.values.firstWhere(
        (c) => c.name == data['category'],
      ),
    );
  }
}
