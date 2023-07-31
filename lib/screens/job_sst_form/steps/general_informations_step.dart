import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';

class GeneralInformationsStep extends StatelessWidget {
  const GeneralInformationsStep({
    super.key,
    required this.enterprise,
    required this.job,
  });

  final Enterprise enterprise;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Nom de l\'entreprise'),
              controller: TextEditingController(text: enterprise.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Secteur d\'activité'),
              controller:
                  TextEditingController(text: job.specialization.sector.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Métier semi-spécialisé'),
              controller: TextEditingController(text: job.specialization.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration: const InputDecoration(labelText: 'Année scolaire'),
              controller: TextEditingController(text: '2022-2023'),
              enabled: false,
            ),
          ),
          const SubTitle('Objectifs'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objectif principal\u00a0: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16, top: 8),
                  child: Text(
                    'Susciter un dialogue avec les entreprises sur la santé et '
                    'la sécurité du travail (SST).',
                  ),
                ),
                Text(
                  'Objectif spécifiques\u00a0: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const ItemizedText([
                  'Éclairer les enseignants sur de possibles risques pour la '
                      'SST des élèves en stage',
                  'Faire prendre conscience aux entreprises que l\'enseignant '
                      'est attentif à la SST et est un partenaire pour former '
                      'l\'élève sur ce sujet.',
                ]),
              ],
            ),
          ),
          const SubTitle('Cible'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Entreprise dans laquelle l\'élève est placé pour la '
              'première fois en stage.',
            ),
          ),
          const SubTitle('Recommandations'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remplir ce formulaire lors d\'un entretien\u00a0:',
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemizedText([
                        'Avec la personne qui est en charge de former '
                            'l\'élève sur le plancher:'
                      ]),
                      Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: ItemizedText([
                            'C\'est elle qui connait le mieux le poste de '
                                'travail de l\'élève',
                            'Il sera plus facile d\'aborder avec elle qu\'avec '
                                'les employeurs les questions relatives aux '
                                'dangers et aux accidents)',
                          ])),
                      ItemizedText([
                        'La 1ère semaine de stage',
                        'Pendant (ou à la suite) d\'une visite du poste de '
                            'travail de l\'élève',
                      ])
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text('Quand:'),
                ItemizedText([
                  'La 1ère semaine de stage',
                  'Pendant (ou à la suite) d\'une visite du poste de travail '
                      'de l\'élève',
                ]),
                SizedBox(height: 12),
                Text('Durée de remplissage\u00a0: 15 minutes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
