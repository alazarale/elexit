import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../models/exam_model.dart';
import 'package:flutter_tex/flutter_tex.dart';

class Quiz {
  final String statement;
  final List<QuizOption> options;
  final String correctOptionId;

  Quiz({
    required this.statement,
    required this.options,
    required this.correctOptionId,
  });
}

class QuizOption {
  final String id;
  final String option;

  QuizOption(this.id, this.option);
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<SubjectModel> subjects = [];
  late Database db;
  int sub_id = 2;
  bool isLoading = true;
  SplayTreeMap chapters = SplayTreeMap();
  var chaps_map = {};
  var exams_map = {};
  var res_map = {};
  var rp_data = {};
  var tp_data = {};

  int currentQuizIndex = 0;
  String selectedOptionId = "";
  bool isWrong = false;

  List<Quiz> quizList = [
    Quiz(
      statement: r"""<h3>What is the correct form of quadratic formula?</h3>""",
      options: [
        QuizOption(
          "id_1",
          r""" <h2><span style="border: 1px solid #757575; padding: 2px 10px; margin-right:10px;">A</span>   \(x = {-b \pm \sqrt{b^2+4ac} \over 2a}\)</h3>""",
        ),
        QuizOption(
          "id_2",
          r""" <h2>\(x = {b \pm \sqrt{b^2-4ac} \over 2a}\)</h3>""",
        ),
        QuizOption(
          "id_3",
          r""" <h2>\(x = {-b \pm \sqrt{b^2-4ac} \over 2a}\)</h2>""",
        ),
        QuizOption(
          "id_4",
          r""" <h2>\(x = {-b + \sqrt{b^2+4ac} \over 2a}\)</h2>""",
        ),
      ],
      correctOptionId: "id_3",
    ),
    Quiz(
      statement:
          r"""<h3>Choose the correct mathematical form of Bohr's Radius.</h3>""",
      options: [
        QuizOption(
          "id_1",
          r""" <h2>(A)   \( a_0 = \frac{{\hbar ^2 }}{{m_e ke^2 }} \)</h2>""",
        ),
        QuizOption(
          "id_2",
          r""" <h2>(B)   \( a_0 = \frac{{\hbar ^2 }}{{m_e ke^3 }} \)</h2>""",
        ),
        QuizOption(
          "id_3",
          r""" <h2>(C)   \( a_0 = \frac{{\hbar ^3 }}{{m_e ke^2 }} \)</h2>""",
        ),
        QuizOption(
          "id_4",
          r""" <h2>(D)   \( a_0 = \frac{{\hbar }}{{m_e ke^2 }} \)</h2>""",
        ),
      ],
      correctOptionId: "id_1",
    ),
    Quiz(
      statement: r"""<h3>Select the correct Chemical Balanced Equation.</h3>""",
      options: [
        QuizOption("id_1", r""" <h2>(A)   \( \ce{CO + C -> 2 CO} \)</h2>"""),
        QuizOption("id_2", r""" <h2>(B)   \( \ce{CO2 + C ->  CO} \)</h2>"""),
        QuizOption("id_3", r""" <h2>(C)   \( \ce{CO + C ->  CO} \)</h2>"""),
        QuizOption("id_4", r""" <h2>(D)   \( \ce{CO2 + C -> 2 CO} \)</h2>"""),
      ],
      correctOptionId: "id_4",
    ),
  ];

  @override
  void initState() {
    super.initState();
    dbstat();

    // This widget is the root of your application.
  }

  dbstat() async {
    setState(() {
      isLoading = false;
      chapters.clear();
      subjects.clear();
      rp_data.clear();
      tp_data.clear();
    });

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "data_init.db");

    db = await openDatabase(path, version: 1);
    final List<Map<String, dynamic>> exams = await db.query(
      'exam',
      where: 'subject=${sub_id}',
    );
    exams.forEach((element) {
      exams_map[element['id']] = element['name'];
    });

    var el = '';
    exams.forEach((element) {
      el == ''
          ? el = element['id'].toString()
          : el = el + ', ' + element['id'].toString();
    });

    final List<Map<String, dynamic>> res = await db.query(
      'result',
      where: 'exam IN (${el})',
    );

    var rs = '';
    res.forEach((element) {
      res_map[element['id']] = element['exam'];
    });

    res.forEach((element) {
      rs == ''
          ? rs = element['id'].toString()
          : rs = rs + ', ' + element['id'].toString();
    });

    final List<Map<String, dynamic>> maps = await db.query(
      'resultchapter',
      where: 'result IN (${rs})',
    );

    final List<Map<String, dynamic>> subs = await db.query('subject');
    List.generate(subs.length, (i) {
      subjects.add(SubjectModel(subs[i]['id'], subs[i]['name']));
    });

    final List<Map<String, dynamic>> chaps = await db.query(
      'chapter',
      where: 'subject=${sub_id}',
    );
    chaps.forEach((element) {
      chaps_map[element['id']] = element['unit'] + ' ' + element['name'];
    });

    maps.forEach((element) {
      if (chapters.keys.contains(element['chapter'])) {
        if (chapters[element['chapter']].keys.contains(element['result'])) {
          chapters[element['chapter']][element['result']].add(element);
        } else {
          chapters[element['chapter']][element['result']] = [element];
        }
      } else {
        chapters[element['chapter']] = {
          element['result']: [element],
        };
      }
      if (rp_data.keys.contains(element['chapter'])) {
        rp_data[element['chapter']].add(
          FlSpot(
            element['result'].toDouble(),
            double.parse(
              ((element['right'] / element['no_questions']) * 100)
                  .toStringAsFixed(1),
            ),
          ),
        );
        tp_data[element['chapter']].add(
          FlSpot(
            element['result'].toDouble(),
            double.parse(
              element['avg_time'].toStringAsFixed(1).replaceAll("-", ""),
            ),
          ),
        );
      } else {
        rp_data[element['chapter']] = [
          FlSpot(
            element['result'].toDouble(),
            double.parse(
              ((element['right'] / element['no_questions']) * 100)
                  .toStringAsFixed(1),
            ),
          ),
        ];
        tp_data[element['chapter']] = [
          FlSpot(
            element['result'].toDouble(),
            double.parse(
              element['avg_time'].toStringAsFixed(1).replaceAll("-", ""),
            ),
          ),
        ];
      }
    });
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 50,
              child: ListView.builder(
                itemCount: subjects.length,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: GestureDetector(
                      onTap: (() {
                        setState(() {
                          sub_id = subjects[index].id;
                          dbstat();
                        });
                      }),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.book,
                                  color: sub_id == subjects[index].id
                                      ? AppTheme.color0081B9
                                      : AppTheme.color7E7E7E,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(
                                    '${subjects[index].name}',
                                    style: TextStyle(
                                      color: sub_id == subjects[index].id
                                          ? AppTheme.color0081B9
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Visibility(
            visible: isLoading,
            replacement: Center(
              child: CircularProgressIndicator(color: AppTheme.color0081B9),
            ),
            child: ListView.builder(
              itemCount: chapters.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '${chaps_map[chapters.keys.elementAt(index)]}',
                            style: TextStyle(
                              color: AppTheme.color21205A,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            itemCount:
                                chapters[chapters.keys.elementAt(index)].length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (BuildContext context, int ind) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${exams_map[res_map[chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)]]}',
                                        style: TextStyle(
                                          color: AppTheme.color3275a8,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${((chapters[chapters.keys.elementAt(index)][chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)][0]['right'] / chapters[chapters.keys.elementAt(index)][chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)][0]['no_questions']) * 100).toStringAsFixed(1)} %',
                                        style: TextStyle(
                                          color: AppTheme.color0081B9,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  LinearPercentIndicator(
                                    width: devWidth - 60,
                                    animation: true,
                                    lineHeight: 10.0,
                                    animationDuration: 1000,
                                    percent:
                                        chapters[chapters.keys.elementAt(
                                          index,
                                        )][chapters[chapters.keys.elementAt(
                                              index,
                                            )]
                                            .keys
                                            .elementAt(ind)][0]['right'] /
                                        chapters[chapters.keys.elementAt(
                                          index,
                                        )][chapters[chapters.keys.elementAt(
                                              index,
                                            )]
                                            .keys
                                            .elementAt(ind)][0]['no_questions'],
                                    barRadius: Radius.circular(10),
                                    progressColor: AppTheme.color0081B9,
                                    backgroundColor: AppTheme.colorE1E9F9,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
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
                                        "${chapters[chapters.keys.elementAt(index)][chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)][0]['right']}/${chapters[chapters.keys.elementAt(index)][chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)][0]['no_questions']}",
                                        style: TextStyle(
                                          color: AppTheme.color0081B9,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
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
                                        "${chapters[chapters.keys.elementAt(index)][chapters[chapters.keys.elementAt(index)].keys.elementAt(ind)][0]['avg_time'].toStringAsFixed(1)} s",
                                        style: TextStyle(
                                          color: AppTheme.color0081B9,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 40),
                                ],
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            height: 150,
                            child: LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minY: 0,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots:
                                        rp_data[chapters.keys.elementAt(index)],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Result Progress',
                              style: TextStyle(
                                color: AppTheme.color0081B9,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            height: 150,
                            child: LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minY: 0,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots:
                                        tp_data[chapters.keys.elementAt(index)],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Time/Question Progress',
                              style: TextStyle(
                                color: AppTheme.color0081B9,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
