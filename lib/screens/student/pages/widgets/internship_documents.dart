import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';
import 'package:crcrme_banque_stages/screens/student/JsonToPdf/tag_system/tag_handler.dart';

class InternshipDocuments extends StatefulWidget {
  const InternshipDocuments({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipDocuments> createState() => _InternshipDocumentsState();
}

class _InternshipDocumentsState extends State<InternshipDocuments> {
  bool _isExpanded = false;

  int _getInternshipSectorNumber() {
    final specialization = EnterprisesProvider.of(context,
            listen: false)[widget.internship.enterpriseId]
        .jobs[widget.internship.jobId]
        .specialization;
    return int.parse(specialization.sector.id);
  }

  Future<String> preprocessJSONTags(String jsonString) async {
    var jsonData = json.decode(jsonString);
    TagHandler tagsHandler =
        TagHandler(context: context, internship: widget.internship);
    jsonData['pages'] = await tagsHandler.processElementsRecursively(
        jsonData['pages'], tagsHandler);
    return json.encode(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) =>
            setState(() => _isExpanded = !_isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Text('Documents',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPdfTile(
                  context,
                  title: 'Formulaire d\'identification du stagiaire',
                  pdfGeneratorCallback: ((format,
                          {required internship, preprocessJsonCallback}) =>
                      GenerateDocuments.generateStudentIdentificationPdf(format,
                          internship: internship,
                          preprocessJsonCallback: preprocessJSONTags,
                          context: context)),
                ),
                ...List.generate(
                  widget.internship.nbVersions,
                  (index) => _buildPdfTile(
                    context,
                    title: 'Contrat de stage - Version du '
                        '${DateFormat('yMd', 'fr_CA').format(widget.internship.versionDateFrom(index))}',
                    pdfGeneratorCallback: (format,
                            {required internship, preprocessJsonCallback}) =>
                        GenerateDocuments.generateInternshipContractPdf(format,
                            internship: internship, versionIndex: index),
                  ),
                ),
                _buildPdfTile(
                  context,
                  title: 'Formulaire pour la CNESST',
                  pdfGeneratorCallback: ((format,
                          {required internship, preprocessJsonCallback}) =>
                      GenerateDocuments.generateCnesstPdf(format,
                          internship: internship,
                          preprocessJsonCallback: preprocessJSONTags,
                          context: context)),
                ),
                _buildPdfTile(context,
                    title: "Formulaire pour l'inscription au stage",
                    pdfGeneratorCallback: (((format,
                            {required internship, preprocessJsonCallback}) =>
                        GenerateDocuments.generateInternshipDescriptionPdf(
                            format,
                            internship: internship,
                            preprocessJsonCallback: preprocessJSONTags,
                            context: context)))),
                _buildPdfTile(context,
                    title: 'Formulaire d\'autorisation de prise de photos',
                    pdfGeneratorCallback: (((format,
                            {required internship, preprocessJsonCallback}) =>
                        GenerateDocuments.generatePhotoAutorisationPdf(format,
                            internship: internship,
                            preprocessJsonCallback: preprocessJSONTags,
                            context: context)))),
                _buildPdfTile(context,
                    title: 'Formulaire pour le crédit d\'impôts',
                    pdfGeneratorCallback: (((format,
                            {required internship, preprocessJsonCallback}) =>
                        GenerateDocuments.generateTaxeCreditFormPdf(format,
                            internship: internship,
                            preprocessJsonCallback: preprocessJSONTags,
                            context: context)))),
                if (_getInternshipSectorNumber() == 10)
                  _buildPdfTile(context,
                      title: 'Formulaire de demande de carte de stage au Club ',
                      pdfGeneratorCallback: (((format,
                              {required internship, preprocessJsonCallback}) =>
                          GenerateDocuments.generateInternshipAutomotiveCardPdf(
                              format,
                              internship: internship,
                              preprocessJsonCallback: preprocessJSONTags,
                              context: context)))),
                _buildPdfTile(
                  context,
                  title: 'Preuve de couverture d\'assurances',
                  pdfGeneratorCallback: (((format,
                          {required internship, preprocessJsonCallback}) =>
                      GenerateDocuments.generateInsurancePdf(format,
                          internship: internship,
                          preprocessJsonCallback: preprocessJSONTags,
                          context: context))),
                ),
                _buildEvaluations(
                    title: 'Évaluation des compétences',
                    evaluations: widget.internship.skillEvaluations,
                    pdfGeneratorCallback:
                        GenerateDocuments.generateSkillEvaluationPdf),
                _buildEvaluations(
                    title: 'Évaluation des attitudes et comportements',
                    evaluations: widget.internship.attitudeEvaluations,
                    pdfGeneratorCallback:
                        GenerateDocuments.generateAttitudeEvaluationPdf),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPdfTile(
    BuildContext context, {
    required String title,
    required Future<Uint8List> Function(
      PdfPageFormat format, {
      required Internship internship,
      Future<String> Function(String)? preprocessJsonCallback,
    }) pdfGeneratorCallback,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => Dialog(
              child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Center(
                  child: PdfPreview(
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    build: (format) => pdfGeneratorCallback(format,
                        internship: widget.internship),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.blue, // todo: change to theme color
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              )
            ],
          )),
        ),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _buildEvaluations(
      {required String title,
      evaluations,
      required Future<Uint8List> Function(PdfPageFormat format,
              {required Internship internship, required int evaluationIndex})
          pdfGeneratorCallback}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evaluations.isEmpty) const Text('Aucune évalution'),
                if (evaluations.isNotEmpty)
                  ...evaluations.asMap().keys.map(
                        (index) => _buildPdfTile(
                          context,
                          title: 'Formulaire du '
                              '${DateFormat('yMd', 'fr_CA').format(evaluations[index].date)}',
                          pdfGeneratorCallback: (format,
                                  {required internship,
                                  preprocessJsonCallback}) =>
                              pdfGeneratorCallback(format,
                                  internship: internship,
                                  evaluationIndex: index),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
