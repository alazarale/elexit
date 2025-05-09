import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:io';

import '../circle_progress.dart';

class ChapterResultMainScreen extends StatefulWidget {
  ChapterResultMainScreen(
      {Key? key,
      required this.right,
      required this.wrong,
      this.chapId})
      : super(key: key);
  List right;
  Map wrong;
  int? chapId;

  @override
  State<ChapterResultMainScreen> createState() =>
      _ChapterResultMainScreenState();
}

class _ChapterResultMainScreenState extends State<ChapterResultMainScreen> {
  bool isLoading = true;
  double perc = 0;
  List<Map<String, dynamic>> maps = [];

  @override
  void initState() {
    super.initState();
    getPerc();
  }

  getPerc() async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");
    var db = await openDatabase(path, version: 1);
    maps = await db.query('question', where: 'chapter=${widget.chapId}');
    print(widget.chapId);
    if (maps != null) {
      setState(() {
        perc = (widget.right.length / maps.length) * 100;
      });
      
      print(perc);
    }
    setState(() {
      
    });

  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color(0xffF2F5F8),
        body: SingleChildScrollView(
          child: Visibility(
            visible: isLoading,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: const Text(
                      'Result Statistics',
                      style: const TextStyle(
                        color: Color(0xff21205A),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                CircularProgressForResult(
                    perc, widget.right.length, maps.length),
                SizedBox(
                  height: 40,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "You have got ${widget.right.length} questions Right",
                              style: TextStyle(
                                color: Color(0xff21205A),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${((widget.right.length / maps.length) * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: LinearPercentIndicator(
                          width: devWidth - 30,
                          animation: true,
                          lineHeight: 10,
                          animationDuration: 1000,
                          percent: widget.right.length / maps.length,
                          barRadius: Radius.circular(10),
                          progressColor: Colors.green,
                          backgroundColor: Color.fromARGB(116, 90, 89, 89),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "You have got ${widget.wrong.length} questions Wrong",
                              style: TextStyle(
                                color: Color(0xff21205A),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${((widget.wrong.length / maps.length) * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: LinearPercentIndicator(
                          width: devWidth - 30,
                          animation: true,
                          lineHeight: 10.0,
                          animationDuration: 1000,
                          percent: widget.wrong.length / maps.length,
                          barRadius: Radius.circular(10),
                          progressColor: Colors.red,
                          backgroundColor: Color.fromARGB(116, 90, 89, 89),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${maps.length - (widget.right.length + widget.wrong.length)} question left unanswered",
                              style: TextStyle(
                                color: Color(0xff21205A),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${(((maps.length - (widget.right.length + widget.wrong.length)) / maps.length) * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: Color(0xff0081B9),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: LinearPercentIndicator(
                          width: devWidth - 30,
                          animation: true,
                          lineHeight: 10.0,
                          animationDuration: 1000,
                          percent: (maps.length -
                                  (widget.right.length + widget.wrong.length)) /
                              maps.length,
                          barRadius: Radius.circular(10),
                          progressColor: Color(0xff0081B9),
                          backgroundColor: Color.fromARGB(116, 90, 89, 89),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
