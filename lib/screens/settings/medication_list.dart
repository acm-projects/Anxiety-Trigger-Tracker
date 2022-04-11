import 'package:flutter/material.dart';
import 'package:anxiety_align/screens/settings/medication.dart';
import 'package:anxiety_align/services/auth.dart';
import 'package:anxiety_align/services/database.dart';

class MedicationList extends StatefulWidget {
  const MedicationList({Key? key}) : super(key: key);
  @override
  State<MedicationList> createState() => _MedicationListState();
}

class _MedicationListState extends State<MedicationList> {
  late DatabaseService database;
  late final String userID;
  late int index;
  late List<String> names;
  late List<int> dosages;
  late List<List<String>> days;
  late List<int> frequencies;
  Widget? buildHelper;

  @override
  void initState() {
    userID = AuthService().currUserID!;
    initAsync();
    super.initState();
  }

  Future<void> initAsync() async {
    await updateMedications();
    index = names.isEmpty ? -1 : 0;
    buildMedication();
  }

  Future<void> updateMedications() async {
    database = DatabaseService(userID: userID);
    names = await database.getMedicationName();
    dosages = (await database.getDosage()).map((dosage) => int.parse(dosage))
      .toList();
    days = (await database.getDays()).map((days) => days.cast<String>())
      .toList();
    frequencies = await database.getFreq();
  }

  @override
  Widget build(BuildContext context) => buildHelper ?? const Medication(
    noMedications: true
  );

  void buildMedication() =>
    setState(() => buildHelper = index == -1 ? const Medication(
      noMedications: true
    ) : Medication(
      name: names[index],
      dosage: dosages[index],
      days: days[index],
      frequency: frequencies[index],
      previousMedication: index == 0 ? null : previousMedication,
      nextMedication: index == names.length - 1 ? null : nextMedication,
      removeMedication: removeMedication
    )
  );

  void previousMedication() {
    index--;
    buildMedication();
  }

  void nextMedication() {
    index++;
    buildMedication();
  }

  Future<void> removeMedication(String name) async {
    await database.removeMed(name);
    await updateMedications();
    if(index != 0) index--;
    if(names.isEmpty) index = -1;
    buildMedication();
  }
}
