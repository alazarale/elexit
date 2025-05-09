import 'dart:ffi';

import 'package:eltest_exit/models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tex/flutter_tex.dart';

import 'circle_progress.dart';
import 'feedback_dialog.dart';
import 'service/common.dart';

class WrongAnswer extends StatefulWidget {
  WrongAnswer({Key? key, this.exam_title, this.exam_id, this.exam_time})
    : super(key: key);

  String? exam_title;
  int? exam_id;
  int? exam_time;

  @override
  State<WrongAnswer> createState() => _WrongAnswerState();
}

class _WrongAnswerState extends State<WrongAnswer> {
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
  List<TeXViewWidget> ques_tex = [];

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
      print(res_wrong);
      int q_count = 0;
      res_wrong.forEach((value) {
        q_count++;
        ques_tex.add(
          _teXViewWidget(
            questionMap[value['question'].toString()]['ques'],
            questionMap[value['question'].toString()]['a'],
            questionMap[value['question'].toString()]['b'],
            questionMap[value['question'].toString()]['c'],
            questionMap[value['question'].toString()]['d'],
            questionMap[value['question'].toString()]['ans'],
            q_count,
            questionMap[value['question'].toString()]['image'],
            value['choosen'],
          ),
        );
      });

      setState(() {
        perc = (_rights.length / _totalQuestion) * 100;
        wrongRes = res_wrong;
      });
    }
  }

  static TeXViewWidget _teXViewWidget(
    String title,
    String a,
    String b,
    String c,
    String d,
    String ans,
    int q_c,
    String? imgs,
    String? choosen,
  ) {
    return TeXViewColumn(
      style: const TeXViewStyle(
        margin: TeXViewMargin.all(10),
        padding: TeXViewPadding.all(10),
        backgroundColor: Colors.white,
        elevation: 3,
      ),
      children: [
        TeXViewDocument(
          'Question ' + q_c.toString(),
          style: TeXViewStyle(
            padding: TeXViewPadding.all(10),
            textAlign: TeXViewTextAlign.center,
            fontStyle: TeXViewFontStyle(
              fontWeight: TeXViewFontWeight.bold,
              fontSize: 20,
            ),
            contentColor: Colors.blue,
          ),
        ),
        TeXViewDocument(
          imgs == null
              ? title
              : title + '<br><img src="${main_url}$imgs" style="width: 300px">',
          style: TeXViewStyle.fromCSS(
            'overflow: scroll; padding: 15px; color: white; background: #0081B9; border-radius: 10px;',
          ),
        ),
        TeXViewDocument(
          ans == 'a'
              ? "<div style='display: flex; color: green;'><span style='border: 1px solid green; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: green; color: white'>A</span>" +
                  a +
                  "</div>"
              : choosen == 'A'
              ? "<div style='display: flex; color: red;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: red; color: white'>A</span>" +
                  a +
                  "</div>"
              : "<div style='display: flex; color: #757575;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px;'>A</span>" +
                  a +
                  "</div>",
          style: const TeXViewStyle(padding: TeXViewPadding.all(15)),
        ),
        TeXViewDocument(
          ans == 'b'
              ? "<div style='display: flex; color: green;'><span style='border: 1px solid green; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: green; color: white'>B</span>" +
                  b +
                  "</div>"
              : choosen == 'B'
              ? "<div style='display: flex; color: red;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: red; color: white'>B</span>" +
                  b +
                  "</div>"
              : "<div style='display: flex; color: #757575;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px;'>B</span>" +
                  b +
                  "</div>",
          style: const TeXViewStyle(padding: TeXViewPadding.all(15)),
        ),
        TeXViewDocument(
          ans == 'c'
              ? "<div style='display: flex; color: green;'><span style='border: 1px solid green; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: green; color: white'>C</span>" +
                  c +
                  "</div>"
              : choosen == 'C'
              ? "<div style='display: flex; color: red;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: red; color: white'>C</span>" +
                  c +
                  "</div>"
              : "<div style='display: flex; color: #757575;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px;'>C</span>" +
                  c +
                  "</div>",
          style: const TeXViewStyle(padding: TeXViewPadding.all(15)),
        ),
        TeXViewDocument(
          ans == 'd'
              ? "<div style='display: flex; color: green;'><span style='border: 1px solid green; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: green; color: white'>D</span>" +
                  d +
                  "</div>"
              : choosen == 'D'
              ? "<div style='display: flex; color: red;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px; background: red; color: white'>D</span>" +
                  d +
                  "</div>"
              : "<div style='display: flex; color: #757575;'><span style='border: 1px solid #757575; padding: 2px 10px; padding-top: 6px; margin-right:15px;'>D</span>" +
                  d +
                  "</div>",
          style: const TeXViewStyle(padding: TeXViewPadding.all(15)),
        ),
      ],
    );
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
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Center(
                  child: const Text(
                    'Wrong Answers',
                    style: const TextStyle(
                      color: Color(0xff21205A),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TeXView(child: TeXViewColumn(children: ques_tex)),
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
                      Color.fromARGB(255, 255, 255, 255),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xff0081B9),
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
}
