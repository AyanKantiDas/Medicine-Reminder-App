import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_medicine/common/convert_time.dart';
import 'package:flutter_medicine/global_bloc.dart';
import 'package:flutter_medicine/model/errors.dart';
import 'package:flutter_medicine/model/medicine.dart';
import 'package:flutter_medicine/model/medicine_type.dart';
import 'package:flutter_medicine/pages/home_page.dart';
import 'package:flutter_medicine/pages/new_entry/new_entry_bloc.dart';
import 'package:flutter_medicine/success_screen/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late NewEntryBloc _newEntryBloc;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
    _newEntryBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    _scaffoldKey = GlobalKey<ScaffoldState>();

    _newEntryBloc = NewEntryBloc();
    initializeNotifications();
    initializeErrorListen();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add Medicine'),
        centerTitle: true,
      ),
      body: Provider<NewEntryBloc>.value(
        value: _newEntryBloc,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PanelTitle(
                  title: "Medicine Name",
                  isRequired: true,
                ),
                TextFormField(
                  maxLength: 20,
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: const Color.fromARGB(255, 36, 81, 117)),
                ),
                const PanelTitle(
                  title: "Dosage in mg",
                  isRequired: false,
                ),
                TextFormField(
                  maxLength: 20,
                  controller: dosageController,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: const Color.fromARGB(255, 36, 81, 117)),
                ),
                SizedBox(
                  height: 1.h,
                ),
                const PanelTitle(title: 'Medicine Type', isRequired: false),
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: StreamBuilder<MedicineType>(
                    stream: _newEntryBloc.selectedMedicineType,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MedicineTypeColumn(
                              medicineType: MedicineType.Pill,
                              name: 'Pill',
                              iconValue:
                                  'assets/icons/output-onlinegiftools.gif',
                              isSelected: snapshot.data == MedicineType.Pill
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Bottle,
                              name: 'Bottle',
                              iconValue:
                                  'assets/icons/medical-removebg-preview.png',
                              isSelected: snapshot.data == MedicineType.Bottle
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Syringe,
                              name: 'Syringe',
                              iconValue: 'assets/icons/syringe1.gif',
                              isSelected: snapshot.data == MedicineType.Syringe
                                  ? true
                                  : false),
                          MedicineTypeColumn(
                              medicineType: MedicineType.Tablet,
                              name: 'Tablet',
                              iconValue: 'assets/icons/tablet1.gif',
                              isSelected: snapshot.data == MedicineType.Tablet
                                  ? true
                                  : false)
                        ],
                      );
                    },
                  ),
                ),
                const PanelTitle(title: 'Interval Selection', isRequired: true),
                const IntervalSelection(),
                const PanelTitle(title: "Starting Time", isRequired: true),
                const SelectTime(),
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w),
                  child: SizedBox(
                    width: 80.w,
                    height: 8.h,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 145, 245, 190),
                          shape: const StadiumBorder()),
                      onPressed: () {
                        String? medicineName;
                        int? dosage;
                        if (nameController.text == "") {
                          _newEntryBloc.submitError(EntryError.nameNull);
                          return;
                        }
                        if (nameController.text != "") {
                          medicineName = nameController.text;
                        }
                        if (dosageController.text == "") {
                          dosage = 0;
                        }
                        if (dosageController.text != "") {
                          dosage = int.parse(dosageController.text);
                        }
                        for (var medicine in globalBloc.medicineList$!.value) {
                          if (medicineName == medicine.medicineName) {
                            _newEntryBloc.submitError(EntryError.nameDuplicate);
                            return;
                          }
                        }
                        if (_newEntryBloc.selectIntervals!.value == 0) {
                          _newEntryBloc.submitError(EntryError.interval);
                          return;
                        }
                        if (_newEntryBloc.selectedTimeOfDay$!.value == 'None') {
                          _newEntryBloc.submitError(EntryError.startTime);
                          return;
                        }

                        String medicineType = _newEntryBloc
                            .selectedMedicineType!.value
                            .toString()
                            .substring(13);

                        int interval = _newEntryBloc.selectIntervals!.value;
                        String startTime =
                            _newEntryBloc.selectedTimeOfDay$!.value;

                        List<int> intIDs =
                            makeIDs(24 / _newEntryBloc.selectIntervals!.value);
                        List<String> notificationIDs =
                            intIDs.map((i) => i.toString()).toList();

                        Medicine newEntryMedicine = Medicine(
                          notificationIDs: notificationIDs,
                          medicineName: medicineName,
                          dosage: dosage,
                          medicineType: medicineType,
                          interval: interval,
                          startTime: startTime,
                        );
                        globalBloc.updateMedicineList(newEntryMedicine);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SuccessScreen()));
                        scheduleNotification(newEntryMedicine);
                      },
                      child: const Center(
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$!.listen((EntryError error) {
      switch (error) {
        case EntryError.nameNull:
          displayError("Please enter the medicine's name");
          break;
        case EntryError.nameDuplicate:
          displayError("Medicine name already exists");
          break;
        case EntryError.dosage:
          displayError("Please enter the dosage required");
          break;
        case EntryError.interval:
          displayError("Please select the reminder's interval");
          break;
        case EntryError.startTime:
          displayError("Please select the reminder's starting time");
          break;
        default:
      }
    });
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      duration: const Duration(milliseconds: 2000),
      backgroundColor: const Color.fromARGB(255, 145, 245, 190),
    ));
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          debugPrint("notification payload: ${notificationResponse.payload}");
        }
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
    );

    // Initialize timezone data
    tz.initializeTimeZones();

    // Request permissions on Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      await _requestNotificationPermission();
    }
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (Theme.of(context).platform == TargetPlatform.android &&
        !status.isGranted) {
      debugPrint("Notification permission denied");
      return;
    }

    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        var status = await Permission.scheduleExactAlarm.request();
        if (status.isDenied) {
          debugPrint("Exact alarm permission denied");
        }
      }
    }
  }

  Future<void> scheduleNotification(Medicine medicine) async {
    var hour = int.parse(medicine.startTime!.substring(0, 2));
    var minute = int.parse(medicine.startTime!.substring(2, 4));
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'repeatDailyAtTime_channel_id',
      'repeatDailyAtTime_channel_name',
      importance: Importance.max,
      ledColor: Color.fromARGB(255, 166, 221, 168),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Calculate initial notification time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule notifications at custom intervals
    await flutterLocalNotificationsPlugin.zonedSchedule(
      int.parse(medicine.notificationIDs![0]),
      'Reminder: ${medicine.medicineName}',
      medicine.medicineType.toString() != MedicineType.None.toString()
          ? 'It is time to take your ${medicine.medicineType!.toLowerCase()}, according to schedule'
          : 'It is time to take your medicine, according to schedule',
      scheduledTime,
      platformChannelSpecifics,
      payload: 'Medicine Notification',
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );

    // Repeat notifications
    var interval = Duration(hours: medicine.interval!);
    var nextNotificationTime = scheduledTime.add(interval);
    while (nextNotificationTime.isBefore(now.add(const Duration(days: 365)))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(medicine.notificationIDs![0]),
        'Reminder: ${medicine.medicineName}',
        medicine.medicineType.toString() != MedicineType.None.toString()
            ? 'It is time to take your ${medicine.medicineType!.toLowerCase()}, according to schedule'
            : 'It is time to take your medicine, according to schedule',
        nextNotificationTime,
        platformChannelSpecifics,
        payload: 'Medicine Notification',
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
      nextNotificationTime = nextNotificationTime.add(interval);
    }
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({super.key});

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay?> _selectTime() async {
    final NewEntryBloc newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;
        newEntryBloc.updateTime(convertTime(_time.hour.toString()) +
            convertTime(_time.minute.toString()));
      });
    }

    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 11.h,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 145, 245, 190),
                shape: const StadiumBorder()),
            onPressed: () {
              _selectTime();
            },
            child: Center(
              child: Text(
                _clicked == false
                    ? "Select Time"
                    : "${convertTime(_time.hour.toString())}: ${convertTime(_time.minute.toString())}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            )),
      ),
    );
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({super.key});

  @override
  State<IntervalSelection> createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [
    6,
    8,
    12,
    24,
  ];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            // Wrap the first text in a Column to allow vertical alignment
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text at the start
            children: [
              Text(
                'Remind Me Everyday',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          DropdownButton(
            iconEnabledColor: const Color.fromARGB(255, 41, 150, 90),
            dropdownColor: Colors.white,
            itemHeight: 8.h,
            hint: _selected == 0
                ? const Text(
                    "Select an Interval",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  )
                : null,
            elevation: 4,
            value: _selected == 0 ? null : _selected,
            items: _intervals.map(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 41, 150, 90),
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                );
              },
            ).toList(),
            onChanged: (newVal) {
              setState(
                () {
                  _selected = newVal!;
                  newEntryBloc.updateInterval(newVal);
                },
              );
            },
          ),
          Text(_selected == 1 ? "hour" : "hours",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class MedicineTypeColumn extends StatelessWidget {
  const MedicineTypeColumn(
      {super.key,
      required this.medicineType,
      required this.name,
      required this.iconValue,
      required this.isSelected});
  final MedicineType medicineType;
  final String name;
  final String iconValue;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return GestureDetector(
      onTap: () {
        newEntryBloc.updateSelectedMedicine(medicineType);
      },
      child: Column(
        children: [
          Container(
            width: 22.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.h),
              color: isSelected
                  ? const Color.fromARGB(255, 145, 245, 190)
                  : const Color.fromARGB(255, 145, 245, 190),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
                child: Image(height: 7.h, image: AssetImage(iconValue)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 1.h,
            ),
            child: Container(
              width: 20.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 145, 245, 190)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ).copyWith(color: isSelected ? Colors.black : Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.title, required this.isRequired});
  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextSpan(
              text: isRequired ? " *" : "",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
