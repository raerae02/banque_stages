import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';

abstract class JobDataFileService {
  static Future<void> loadData() async {
    final file = await rootBundle.loadString("assets/jobs-data.json");
    final json = jsonDecode(file) as List;

    _sectors = List.from(
      json.map((e) => ActivitySector.fromSerialized(e)),
      growable: false,
    );
  }

  static ActivitySector? fromId(String id) {
    return _sectors.firstWhereOrNull((sector) => sector.id == id);
  }

  static Iterable<ActivitySector> filterActivitySectors(String query) {
    int? number = int.tryParse(query);
    if (number != null) {
      return JobDataFileService.sectors.where(
        (sector) => sector.id.contains(number.toString()),
      );
    }
    return JobDataFileService.sectors.where(
      (s) => s.idWithName.toLowerCase().contains(query.toLowerCase()),
    );
  }

  static Iterable<Specialization> filterSpecializations(
    String query,
    ActivitySector? activitySector,
  ) {
    if (activitySector == null) return [];
    int? number = int.tryParse(query);
    if (number != null) {
      return activitySector.specializations.where(
        (s) => s.id.contains(number.toString()),
      );
    }
    return activitySector.specializations.where(
      (s) => s.idWithName.toLowerCase().contains(query.toLowerCase()),
    );
  }

  static List<ActivitySector> get sectors => _sectors;

  static List<ActivitySector> _sectors = [];
}

class ActivitySector extends ItemSerializable {
  ActivitySector.fromSerialized(map)
      : name = map["n"],
        specializations = List.from(
          map["s"].map((e) => Specialization.fromSerialized(e)),
          growable: false,
        ),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw "Activity Sector should not be serialized. Store its ID intead.";
  }

  Specialization? fromId(String id) {
    return specializations.firstWhereOrNull((job) => job.id == id);
  }

  String get idWithName => "${int.tryParse(id)} - $name";

  final String name;
  final List<Specialization> specializations;
}

class Specialization extends ItemSerializable {
  Specialization.fromSerialized(map)
      : name = map["n"],
        skills = List.from(
          map["s"].map((e) => Skill.fromSerialized(e)),
          growable: false,
        ),
        questions = Set.from(map["q"]),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw "Job should not be serialized. Store its ID intead.";
  }

  Skill fromId(String id) {
    return skills.firstWhere((skill) => skill.id == id);
  }

  String get idWithName => "${int.tryParse(id)} - $name";

  final String name;

  final List<Skill> skills;
  final Set<String> questions;
}

class Skill extends ItemSerializable {
  Skill.fromSerialized(map)
      : name = map["n"],
        complexity = map["x"],
        criteria = List.from(map["c"], growable: false),
        tasks = List.from(map["t"], growable: false),
        risks = Set.from(map["r"]),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw "Skill should not be serialized. Store its ID intead.";
  }

  final String name;
  final String complexity;

  final List<String> criteria;
  final List<String> tasks;
  final Set<String> risks;
}
