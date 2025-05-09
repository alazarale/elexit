import 'dart:ffi';

import '../models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';

import '../theme/app_theme.dart';
import 'circle_progress.dart';

class ChapterAnalysis extends StatefulWidget {
  ChapterAnalysis({Key? key, this.exam_title, this.exam_id, this.exam_time})
    : super(key: key);

  String? exam_title;
  int? exam_id;
  int? exam_time;

  @override
  State<ChapterAnalysis> createState() => _ChapterAnalysisState();
}

class _ChapterAnalysisState extends State<ChapterAnalysis> {
  bool isLoading = true;
  int? _resultId;
  var _results;
  List _rights = [];
  ExamModel? _exam;
  int? examId;
  int _totalQuestion = 0;
  double perc = 0;
  List wrongRes = [];
  String? _examTitle;
  List<Map<String, dynamic>> res_chapter = [];
  List<Map<String, dynamic>> res_wrong = [];

  Map<String, double> dataMap = {'none': 3, 'none2': 5};
  Map<String, String> chapterMap = {};
  Map<String, dynamic> questionMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement initState
    super.didChangeDependencies();
    Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    _resultId = arguments['result_id'];
    _examTitle = arguments['title'];

    getResults(_resultId);
  }

  getResults(resultId) async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");
    var db = await openDatabase(path, version: 1);
    final List<Map<String, dynamic>> _r_maps = await db.query(
      'result',
      where: 'id=${resultId}',
    );

    _results = _r_maps[0];
    _rights = _results['right'].toString().split(',');
    _rights.remove('0');

    examId = _results['exam'];
    final List<Map<String, dynamic>> ques = await db.query(
      'question',
      where: 'exam=${examId}',
    );

    _totalQuestion = ques.length;

    res_wrong = await db.query('resultwrong', where: 'result=${resultId}');

    res_chapter = await db.query('resultchapter', where: 'result=${resultId}');

    final List<Map<String, dynamic>> chapters = await db.query('chapter');

    if (_totalQuestion > 0) {
      dataMap.clear();
      res_chapter.forEach((element) {
        chapters.forEach((elem) {
          element['chapter'] == elem['id']
              ? dataMap[elem['unit']] = element['no_questions'].toDouble()
              : null;
        });
      });

      chapters.forEach((element) {
        chapterMap[element['id'].toString()] =
            element['unit'] + ': ' + element['name'];
      });

      ques.forEach((element) {
        questionMap[element['id'].toString()] = element;
      });

      setState(() {
        perc = (_rights.length / _totalQuestion) * 100;
        wrongRes = res_wrong;
      });
      print(dataMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.colorF2F5F8,
      body: SingleChildScrollView(
        child: Visibility(
          visible: isLoading,
          child: Column(
            children: [
              SizedBox(height: 20),
              const Center(
                child: const Text(
                  'Chapter Analysis',
                  style: const TextStyle(
                    color: AppTheme.color21205A,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              PieChart(dataMap: dataMap),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppTheme.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: res_chapter.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                              child: SizedBox(
                                width: devWidth - 30,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        "${chapterMap[res_chapter[index]['chapter'].toString()]}  ",
                                        maxLines: 2,
                                        textAlign: TextAlign.justify,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppTheme.color21205A,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "  ${((res_chapter[index]['right'] / res_chapter[index]['no_questions']) * 100).toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          color: AppTheme.color0081B9,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                              child: LinearPercentIndicator(
                                width: devWidth - 30,
                                animation: true,
                                lineHeight: 10.0,
                                animationDuration: 1000,
                                percent:
                                    res_chapter[index]['right'] /
                                    res_chapter[index]['no_questions'],
                                barRadius: Radius.circular(10),
                                progressColor: AppTheme.color0081B9,
                                backgroundColor: AppTheme.colorE1E9F9,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Scored: ",
                                    style: TextStyle(
                                      color: AppTheme.color0081B9,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${res_chapter[index]['right']}/${res_chapter[index]['no_questions']}",
                                    style: TextStyle(
                                      color: AppTheme.color0081B9,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "AVG. time / question: ",
                                    style: TextStyle(
                                      color: AppTheme.color0081B9,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${res_chapter[index]['avg_time'].toStringAsFixed(1)} s",
                                    style: TextStyle(
                                      color: AppTheme.color0081B9,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/take',
                          arguments: {
                            "exam_id": widget.exam_id,
                            'title': widget.exam_title,
                            'time': widget.exam_time,
                          },
                        );
                      },
                      child: Text("Retake Exam"),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.white,
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.color0081B9,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
