import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/form_fields/enterprise_picker_form_field.dart';
import '/common/widgets/form_fields/job_form_field_list_tile.dart';
import '/common/widgets/form_fields/student_picker_form_field.dart';
import '/common/widgets/phone_list_tile.dart';
import '/common/widgets/sub_title.dart';
import '/misc/form_service.dart';
import '/misc/job_data_file_service.dart';

class GeneralInformationsStep extends StatefulWidget {
  const GeneralInformationsStep(
      {super.key, required this.enterprise, required this.student});

  final Enterprise? enterprise;
  final Student? student;

  @override
  State<GeneralInformationsStep> createState() =>
      GeneralInformationsStepState();
}

class GeneralInformationsStepState extends State<GeneralInformationsStep> {
  final formKey = GlobalKey<FormState>();

  late Enterprise? enterprise = widget.enterprise;
  late bool enterpriseIsFixed = widget.enterprise != null;
  late Student? student = widget.student;
  late bool studentIsFixed = widget.student != null;

  Job? primaryJob;
  final List<Specialization?> extraSpecializations = [];

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GeneralInformations(
            enterprise: enterprise,
            enterpriseIsFixed: enterpriseIsFixed,
            onSelectEnterprise: (e) => setState(() => enterprise = e),
            student: student,
            studentIsFixed: studentIsFixed,
            onSelectStudent: (s) => setState(() => student = s),
          ),
          _MainJob(
            enterprise: enterprise,
            onSaved: (job) => setState(() => primaryJob = job),
          ),
          if (student != null && student!.program == Program.fpt)
            _ExtraSpecialization(
              extraSpecializations: extraSpecializations,
              onAddSpecialization: () =>
                  setState(() => extraSpecializations.add(null)),
              onSetSpecialization: (specialization, i) =>
                  setState(() => extraSpecializations[i] = specialization),
              onDeleteSpecialization: (i) =>
                  setState(() => extraSpecializations.removeAt(i)),
            ),
          _SupervisonInformation(
            enterprise: enterprise,
            onSavedFirstName: (name) => supervisorFirstName = name!,
            onSavedLastName: (name) => supervisorLastName = name!,
            onSavedPhone: (phone) => supervisorPhone = phone!,
            onSavedEmail: (email) => supervisorEmail = email!,
          ),
        ],
      ),
    );
  }
}

class _GeneralInformations extends StatelessWidget {
  const _GeneralInformations({
    required this.enterprise,
    required this.enterpriseIsFixed,
    required this.onSelectEnterprise,
    required this.student,
    required this.studentIsFixed,
    required this.onSelectStudent,
  });

  final Enterprise? enterprise;
  final bool enterpriseIsFixed;
  final Function(Enterprise?) onSelectEnterprise;
  final Student? student;
  final bool studentIsFixed;
  final Function(Student?) onSelectStudent;

  List<Student> _studentsWithoutInternship(context, StudentsProvider students) {
    final List<Student> out = [];
    for (final student in students) {
      if (!student.hasActiveInternship(context)) out.add(student);
    }

    return out;
  }

  List<Enterprise> _enterprisesWithAtLeastOneInternshipAvailable(
      context, EnterprisesProvider enterprises) {
    final List<Enterprise> out = [];
    for (final enterprise in enterprises) {
      if (enterprise.availableJobs(context).isNotEmpty) out.add(enterprise);
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Informations générales', left: 0, top: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (enterpriseIsFixed)
                TextField(
                  decoration: const InputDecoration(labelText: '* Entreprise'),
                  controller: TextEditingController(text: enterprise!.name),
                  enabled: false,
                ),
              if (!enterpriseIsFixed)
                Consumer<EnterprisesProvider>(
                  builder: (context, enterprises, _) =>
                      EnterprisePickerFormField(
                    enterprises: _enterprisesWithAtLeastOneInternshipAvailable(
                        context, enterprises),
                    onSaved: onSelectEnterprise,
                    onSelect: onSelectEnterprise,
                  ),
                ),
              if (studentIsFixed)
                TextField(
                  decoration: const InputDecoration(labelText: '* Élève'),
                  controller: TextEditingController(text: student!.fullName),
                  enabled: false,
                ),
              if (!studentIsFixed)
                Consumer<StudentsProvider>(
                  builder: (context, students, _) => StudentPickerFormField(
                    students: _studentsWithoutInternship(context, students),
                    onSaved: onSelectStudent,
                    onSelect: onSelectStudent,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainJob extends StatelessWidget {
  const _MainJob({required this.enterprise, required this.onSaved});

  final Enterprise? enterprise;
  final Function(Job?) onSaved;

  Map<Specialization, int> _generateSpecializationAndAvailability(context) {
    final Map<Specialization, int> out = {};
    if (enterprise == null) return out;
    for (final job in enterprise!.availableJobs(context)) {
      out[job.specialization] = job.positionsRemaining(context);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Métier principal', left: 0),
        JobFormFieldListTile(
          specializations: _generateSpecializationAndAvailability(context),
          askNumberPositionsOffered: false,
          onSaved: onSaved,
        )
      ],
    );
  }
}

class _ExtraSpecialization extends StatelessWidget {
  const _ExtraSpecialization({
    required this.extraSpecializations,
    required this.onAddSpecialization,
    required this.onSetSpecialization,
    required this.onDeleteSpecialization,
  });

  final List<Specialization?> extraSpecializations;
  final Function() onAddSpecialization;
  final Function(Specialization, int) onSetSpecialization;
  final Function(int) onDeleteSpecialization;

  Widget _extraJobTileBuilder(context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Métier supplémentaire ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => onDeleteSpecialization(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
        JobFormFieldListTile(
          onSaved: (job) => onSetSpecialization(job!.specialization, index),
          askNumberPositionsOffered: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Métiers supplémentaires', left: 0),
        Text('(ajout de compétences additionnelles)',
            style: Theme.of(context).textTheme.bodyLarge),
        if (extraSpecializations.isNotEmpty)
          ...extraSpecializations
              .asMap()
              .keys
              .map<Widget>((i) => _extraJobTileBuilder(context, i))
              .toList(),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12),
          child: AddJobButton(
            onPressed: onAddSpecialization,
            style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: Theme.of(context)
                    .elevatedButtonTheme
                    .style!
                    .backgroundColor),
          ),
        ),
      ],
    );
  }
}

class _SupervisonInformation extends StatefulWidget {
  const _SupervisonInformation({
    required this.enterprise,
    required this.onSavedFirstName,
    required this.onSavedLastName,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Enterprise? enterprise;
  final Function(String?) onSavedFirstName;
  final Function(String?) onSavedLastName;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;

  @override
  State<_SupervisonInformation> createState() => _SupervisonInformationState();
}

class _SupervisonInformationState extends State<_SupervisonInformation> {
  bool _useContactInfo = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  void _toggleUseContactInfo() {
    _useContactInfo = !_useContactInfo;
    if (_useContactInfo) {
      _firstNameController.text = widget.enterprise?.contact.firstName ?? '';
      _lastNameController.text = widget.enterprise?.contact.lastName ?? '';
      _phoneController.text = widget.enterprise?.phone.toString() ?? '';
      _emailController.text = widget.enterprise?.contact.email ?? '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Superviseur en milieu de travail', left: 0),
        const Text('(Responsable en milieu de stage)'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Identique au contact',
                style: Theme.of(context).textTheme.titleMedium),
            Switch(
              onChanged: widget.enterprise == null
                  ? null
                  : (newValue) => _toggleUseContactInfo(),
              value: _useContactInfo,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: '* Prénom'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un prénom.' : null,
                onSaved: widget.onSavedFirstName,
                enabled: !_useContactInfo,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration:
                    const InputDecoration(labelText: '* Nom de famille'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un nom de famille.' : null,
                onSaved: widget.onSavedLastName,
                enabled: !_useContactInfo,
              ),
              PhoneListTile(
                controller: _phoneController,
                onSaved: widget.onSavedPhone,
                isMandatory: true,
                enabled: !_useContactInfo,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                ),
                validator: FormService.emailValidator,
                onSaved: widget.onSavedEmail,
                keyboardType: TextInputType.emailAddress,
                enabled: !_useContactInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
