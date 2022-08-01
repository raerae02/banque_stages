import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import 'widgets/about_page.dart';
import 'widgets/contact_page.dart';
import 'widgets/jobs_page.dart';
import 'widgets/stage_page.dart';

class EnterpriseDetails extends StatefulWidget {
  const EnterpriseDetails({Key? key}) : super(key: key);

  static const String route = "/enterprise-details";

  @override
  State<EnterpriseDetails> createState() => _EnterpriseDetailsState();
}

class _EnterpriseDetailsState extends State<EnterpriseDetails>
    with SingleTickerProviderStateMixin {
  late final _enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String;

  late final _tabController =
      TabController(initialIndex: 0, length: 4, vsync: this);

  late IconButton _actionButton;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _contactPageKey = GlobalKey<ContactPageState>();
  final _jobsPageKey = GlobalKey<JobsPageState>();
  final _stagePageKey = GlobalKey<StagePageState>();

  void _updateActionButton() {
    late Icon icon;

    if (_tabController.index == 0) {
      icon = _aboutPageKey.currentState?.editing ?? false
          ? const Icon(Icons.save)
          : const Icon(Icons.edit);
    } else if (_tabController.index == 1) {
      icon = _contactPageKey.currentState?.editing ?? false
          ? const Icon(Icons.save)
          : const Icon(Icons.edit);
    } else if (_tabController.index == 2) {
      icon = const Icon(Icons.add);
    } else if (_tabController.index == 3) {
      icon = const Icon(Icons.add);
    }

    setState(() {
      _actionButton = IconButton(
        icon: icon,
        onPressed: () {
          if (_tabController.index == 0) {
            _aboutPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 1) {
            _contactPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 2) {
            _jobsPageKey.currentState?.addJob();
          } else if (_tabController.index == 3) {
            _stagePageKey.currentState?.addStage();
          }

          _updateActionButton();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _updateActionButton();
    _tabController.addListener(() => _updateActionButton());
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
      builder: (context, enterprise, _) => Scaffold(
        appBar: AppBar(
          title: Text(enterprise.name),
          actions: [_actionButton],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: "À propos"),
              Tab(icon: Icon(Icons.person), text: "Contact"),
              Tab(icon: Icon(Icons.location_city_rounded), text: "Métiers"),
              Tab(
                icon: Icon(Icons.notes_rounded),
                text: "Stages",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AboutPage(key: _aboutPageKey, enterprise: enterprise),
            ContactPage(key: _contactPageKey, enterprise: enterprise),
            JobsPage(key: _jobsPageKey, enterprise: enterprise),
            StagePage(key: _stagePageKey, enterprise: enterprise),
          ],
        ),
      ),
      selector: (context, enterprises) => enterprises[_enterpriseId],
    );
  }
}
