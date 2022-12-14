import 'package:enhanced_containers/enhanced_containers.dart';

class Student extends ItemSerializable {
  Student({
    super.id,
    this.name = "",
    DateTime? dateBirth,
    this.photo = "",
    this.phone = "",
    this.email = "",
    this.address = "",
    this.program = "",
    this.group = "",
    this.contactName = "",
    this.contactRole = "",
    this.contactPhone = "",
    this.contactEmail = "",
  }) : dateBirth = dateBirth ?? DateTime(0);

  Student.fromSerialized(map)
      : name = map['n'],
        dateBirth = DateTime.parse(map['d']),
        photo = map['i'],
        phone = map['p'],
        email = map['e'],
        address = map['a'],
        program = map['pr'],
        group = map['gr'],
        contactName = map['cn'],
        contactRole = map['cr'],
        contactPhone = map['cp'],
        contactEmail = map['ce'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'n': name,
      'd': dateBirth.toString(),
      'i': photo,
      'p': phone,
      'e': email,
      'a': address,
      'pr': program,
      'gr': group,
      'cn': contactName,
      'cr': contactRole,
      'cp': contactPhone,
      'ce': contactEmail,
      'id': id,
    };
  }

  Student copyWith({
    String? name,
    DateTime? dateBirth,
    String? phone,
    String? email,
    String? address,
    String? program,
    String? group,
    String? contactName,
    String? contactRole,
    String? contactPhone,
    String? contactEmail,
    String? id,
  }) =>
      Student(
        name: name ?? this.name,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        program: program ?? this.program,
        group: group ?? this.group,
        contactName: contactName ?? this.contactName,
        contactRole: contactRole ?? this.contactRole,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        id: id ?? this.id,
      );

  final String name;
  final DateTime dateBirth;
  final String photo;

  final String phone;
  final String email;
  final String address;

  final String program;
  final String group;

  final String contactName;
  final String contactRole;
  final String contactPhone;
  final String contactEmail;
}