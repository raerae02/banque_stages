import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/search_bar.dart';
import '/dummy_data.dart';
import '/screens/add_enterprise/add_enterprise_screen.dart';
import '/screens/enterprise/enterprise_screen.dart';
import 'widgets/enterprise_card.dart';

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({super.key});

  static const route = "/enterprises-list";

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen> {
  bool _hideNotAvailable = false;

  final _searchController = TextEditingController();

  void _openEnterpriseScreen(Enterprise enterprise) {
    Navigator.pushNamed(
      context,
      EnterpriseScreen.route,
      arguments: enterprise.id,
    );
  }

  List<Enterprise> _filterSelectedEnterprises(List<Enterprise> enterprises) {
    return enterprises.where((enterprise) {
      if (_hideNotAvailable &&
          !enterprise.jobs
              .any((job) => job.positionsOccupied < job.positionsOffered)) {
      } else if (enterprise.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      } else if (enterprise.jobs.any((job) =>
          job.specialization?.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ??
          false)) {
        return true;
      } else if (enterprise.activityTypes.any((type) =>
          type.toLowerCase().contains(_searchController.text.toLowerCase()))) {
        return true;
      }
      return false;
    }).toList();
  }

  List<Enterprise> _sortEnterprisesByName(List<Enterprise> enterprises) {
    final res = List<Enterprise>.from(enterprises);
    res.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return res.toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entreprises"),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AddEnterpriseScreen.route),
            tooltip: "Ajouter une entreprise",
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: SearchBar(controller: _searchController),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Cacher les stages indisponibles"),
            value: _hideNotAvailable,
            onChanged: (value) => setState(() => _hideNotAvailable = value),
          ),
          Selector<EnterprisesProvider, List<Enterprise>>(
            builder: (context, enterprises, child) => Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: enterprises.length,
                itemBuilder: (context, index) => EnterpriseCard(
                  enterprise: enterprises.elementAt(index),
                  onTap: _openEnterpriseScreen,
                ),
              ),
            ),
            selector: (context, enterprises) => _sortEnterprisesByName(
              _filterSelectedEnterprises(enterprises.toList()),
            ),
          ),
          //! Remove this in production
          Consumer<EnterprisesProvider>(
            builder: (context, enterprises, child) => Visibility(
              visible: enterprises.isEmpty,
              child: ElevatedButton(
                  onPressed: () => addDummyEnterprises(enterprises),
                  child: const Text("Add dummy enterprises")),
            ),
          ),
        ],
      ),
    );
  }
}
