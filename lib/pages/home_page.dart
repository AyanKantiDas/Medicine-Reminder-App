import 'package:flutter/material.dart';
import 'package:flutter_medicine/global_bloc.dart';
import 'package:flutter_medicine/model/medicine.dart';
import 'package:flutter_medicine/pages/medicine_details/medicine_details.dart';
import 'package:flutter_medicine/pages/new_entry/medicine_info.dart';
import 'package:flutter_medicine/pages/new_entry/new_entry_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            const TopContainer(),
            SizedBox(height: 2.h),
            const Flexible(
              child: BottomContainer(),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: InkResponse(
              onTap: () {
                // Navigate to the NewEntryPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewEntryPage()),
                );
              },
              child: SizedBox(
                width: 18.w,
                height: 9.h,
                child: Card(
                  color: Colors.red,
                  shape: const CircleBorder(),
                  child: Icon(Icons.add_outlined,
                      color: Colors.white, size: 40.sp),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200, // Position from top
            right: -10, // Position from right
            child: InkResponse(
              onTap: () {
                // Smooth transition to MedicineInfo page
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MedicineInfo(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: SizedBox(
                width: 18.w,
                height: 9.h,
                child: Card(
                  color: Colors.blue,
                  shape: const CircleBorder(),
                  child: Icon(Icons.info_outline,
                      color: Colors.white, size: 40.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            'Ease into Wellness: \nLive healthier.',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            'Step into Wellness: \nYour Daily Dose Awaits!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        StreamBuilder<List<Medicine>>(
          stream: globalBloc.medicineList$,
          builder: (context, snapshot) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 1.h),
              child: Text(
                !snapshot.hasData ? '0' : snapshot.data!.length.toString(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            );
          },
        ),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: Text(
    //     'No Medicines to Take',
    //     textAlign: TextAlign.center,
    //     style: Theme.of(context).textTheme.headlineMedium,
    //   ),
    // );
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return StreamBuilder(
        stream: globalBloc.medicineList$,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No Medicines to Take',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            );
          } else {
            return GridView.builder(
              padding: EdgeInsets.only(top: 1.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return MedicineCard(
                  medicine: snapshot.data![index],
                );
              },
            );
          }
        });
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({super.key, required this.medicine});
  final Medicine medicine;

  Hero makeIcon() {
    if (medicine.medicineType == 'Bottle') {
      return Hero(
          tag: medicine.medicineName! + medicine.medicineType!,
          child: Image.asset(
            'assets/icons/medical-removebg-preview.png',
            height: 10.h,
          ));
    } else if (medicine.medicineType == 'Pill') {
      return Hero(
          tag: medicine.medicineName! + medicine.medicineType!,
          child: Image.asset(
            'assets/icons/output-onlinegiftools.gif',
            height: 10.h,
          ));
    } else if (medicine.medicineType == 'Syringe') {
      return Hero(
          tag: medicine.medicineName! + medicine.medicineType!,
          child: Image.asset(
            'assets/icons/syringe1.gif',
            height: 10.h,
          ));
    } else if (medicine.medicineType == 'Tablet') {
      return Hero(
          tag: medicine.medicineName! + medicine.medicineType!,
          child: Image.asset(
            'assets/icons/tablet1.gif',
            height: 10.h,
          ));
    }
    return Hero(
      tag: medicine.medicineName! + medicine.medicineType!,
      child: Icon(
        Icons.error,
        color: Colors.red,
        size: 10.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.white,
      splashColor: Colors.grey,
      onTap: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => MedicineDetails()));
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, Widget? child) {
                  return Opacity(
                    opacity: animation.value,
                    child: MedicineDetails(medicine),
                  );
                },
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 3.w, right: 2.w, top: 1.h, bottom: 1.h),
        margin: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 232, 232),
          borderRadius: BorderRadius.circular(4.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            makeIcon(),
            Hero(
              tag: medicine.medicineName!,
              child: Text(
                medicine.medicineName!,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Color.fromARGB(255, 196, 40, 40),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0),
              ),
            ),
            Text(
              medicine.interval == 1
                  ? "Every ${medicine.interval} hour"
                  : "Every ${medicine.interval} hour",
              overflow: TextOverflow.fade,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
