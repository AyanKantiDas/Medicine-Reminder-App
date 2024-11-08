import 'package:flutter/material.dart';
import 'package:flutter_medicine/global_bloc.dart';
import 'package:flutter_medicine/model/medicine.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MedicineDetails extends StatefulWidget {
  const MedicineDetails(this.medicine, {super.key});
  final Medicine medicine;

  @override
  State<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            MainSection(
              medicine: widget.medicine,
            ),
            ExtendedSection(
              medicine: widget.medicine,
            ),
            const Spacer(),
            SizedBox(
              width: 80.w,
              height: 7.h,
              child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const StadiumBorder()),
                  onPressed: () {
                    openAlertBox(context, globalBloc);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  )),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }

  openAlertBox(BuildContext context, GlobalBloc globalBloc) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(10),
              ),
            ),
            contentPadding: EdgeInsets.only(top: 1.h),
            title: const Text(
              'Delete This Reminder?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 34, 100, 155)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.w400),
                ),
              ),
              TextButton(
                onPressed: () {
                  globalBloc.removeMedicine(widget.medicine);
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          );
        });
  }
}

class MainSection extends StatelessWidget {
  const MainSection({super.key, this.medicine});
  final Medicine? medicine;

  Hero makeIcon() {
    if (medicine!.medicineType == 'Bottle') {
      return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'assets/icons/medical-removebg-preview.png',
            height: 10.h,
          ));
    } else if (medicine!.medicineType == 'Pill') {
      return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'assets/icons/output-onlinegiftools.gif',
            height: 10.h,
          ));
    } else if (medicine!.medicineType == 'Syringe') {
      return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'assets/icons/syringe1.gif',
            height: 10.h,
          ));
    } else if (medicine!.medicineType == 'Tablet') {
      return Hero(
          tag: medicine!.medicineName! + medicine!.medicineType!,
          child: Image.asset(
            'assets/icons/tablet1.gif',
            height: 10.h,
          ));
    }
    return Hero(
      tag: medicine!.medicineName! + medicine!.medicineType!,
      child: Icon(
        Icons.error,
        color: Colors.red,
        size: 10.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        makeIcon(),
        SizedBox(
          width: 2.w,
        ),
        Column(
          children: [
            Hero(
              tag: medicine!.medicineName!,
              child: Material(
                color: Colors.transparent,
                child: MainInfoTab(
                    fieldTitle: 'Medicine Name',
                    fieldInfo: medicine!.medicineName!),
              ),
            ),
            MainInfoTab(
                fieldTitle: 'Dosage',
                fieldInfo: medicine!.dosage == 0
                    ? 'Not Specified'
                    : "${medicine!.dosage} mg"),
          ],
        ),
      ],
    );
  }
}

class MainInfoTab extends StatelessWidget {
  const MainInfoTab(
      {super.key, required this.fieldTitle, required this.fieldInfo});
  final String fieldTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 12.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 0.3.h),
            Text(
              fieldInfo,
              style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class ExtendedSection extends StatelessWidget {
  const ExtendedSection({super.key, this.medicine});
  final Medicine? medicine;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(
            fielTitle: 'Medicine',
            fieldInfo: medicine!.medicineType! == 'None'
                ? 'Not Specified'
                : medicine!.medicineType!),
        ExtendedInfoTab(
            fielTitle: 'Dose Interval',
            fieldInfo:
                'Every ${medicine!.interval} hours | ${medicine!.interval == 24 ? "One time a day" : "${(24 / medicine!.interval!).floor()} times a day"}'),
        ExtendedInfoTab(
            fielTitle: 'Start Time',
            fieldInfo:
                '${medicine!.startTime![0]}${medicine!.startTime![1]} : ${medicine!.startTime![2]}${medicine!.startTime![3]}'),
      ],
    );
  }
}

class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab(
      {super.key, required this.fielTitle, required this.fieldInfo});
  final String fielTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fielTitle,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 1.h),
          Text(
            fieldInfo,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: Colors.red,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
