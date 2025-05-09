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
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tex/flutter_tex.dart';

import '../theme/app_theme.dart';
import 'circle_progress.dart';
import 'feedback_dialog.dart';
import 'service/common.dart';

class AllQuestion extends StatefulWidget {
  const AllQuestion({Key? key}) : super(key: key);

  @override
  State<AllQuestion> createState() => _AllQuestionState();
}

class _AllQuestionState extends State<AllQuestion> {
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
  var fav_list = [];
  List<Map<String, dynamic>> res_chapter = [];
  List<Map<String, dynamic>> res_wrong = [];
  List<TeXViewWidget> ques_tex = [];

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
      print(questionMap);
      int q_count = 0;
      questionMap.forEach((key, value) {
        q_count++;
        ques_tex.add(
          _teXViewWidget(
            value['ques'],
            value['a'],
            value['b'],
            value['c'],
            value['d'],
            value['ans'],
            q_count,
            value['image'],
          ),
        );
      });
      print(ques_tex);

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
            contentColor: AppTheme.blue,
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
      backgroundColor: AppTheme.colorF2F5F8,
      body: SingleChildScrollView(
        child: Visibility(
          visible: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Center(
                  child: const Text(
                    'All Questions',
                    style: const TextStyle(
                      color: AppTheme.color21205A,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TeXView(child: TeXViewColumn(children: ques_tex)),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: ScrollPhysics(),
                //   itemCount: questionMap.length,
                //   itemBuilder: (context, index) {
                //     return Card(
                //       child: Column(
                //         children: [
                //           Padding(
                //             padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                //             child: Center(
                //               child: Text(
                //                 'Question ${index + 1}',
                //                 style: TextStyle(
                //                     color: Colors.blue,
                //                     fontSize: 18,
                //                     fontWeight: FontWeight.bold),
                //               ),
                //             ),
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                //             child: Html(
                //               data:
                //                   "<p>${questionMap[questionMap.keys.elementAt(index)]['ques']}</p>",
                //               style: {
                //                 "p": Style(
                //                     color: AppTheme.color757575,
                //                     fontSize: FontSize(18),
                //                     fontWeight: FontWeight.bold),
                //               },
                //             ),
                //           ),
                //           questionMap[questionMap.keys.elementAt(index)]
                //                       ['image'] !=
                //                   null
                //               ? SizedBox(
                //                   height: 150,
                //                   child: questionMap[questionMap.keys
                //                               .elementAt(index)]['image'] !=
                //                           null
                //                       ? Image.network(
                //                           '${main_url}${questionMap[questionMap.keys.elementAt(index)]['image']}')
                //                       : Text(''),
                //                 )
                //               : SizedBox(
                //                   height: 0,
                //                 ),
                //           Divider(),
                //           Row(
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.only(left: 20),
                //                 child: Column(
                //                   children: [
                //                     Container(
                //                       height: 35.0,
                //                       width: 35.0,
                //                       child: Center(
                //                         child: Text('A',
                //                             style: TextStyle(
                //                                 color: questionMap[questionMap
                //                                                 .keys
                //                                                 .elementAt(
                //                                                     index)]
                //                                             ['ans'] ==
                //                                         'a'
                //                                     ? Colors.green
                //                                     : AppTheme.color757575,
                //                                 //fontWeight: FontWeight.bold,
                //                                 fontSize: 18.0)),
                //                       ),
                //                       decoration: BoxDecoration(
                //                         color: Colors.transparent,
                //                         border: Border.all(
                //                           width: 1.0,
                //                           color: questionMap[questionMap.keys
                //                                           .elementAt(index)]
                //                                       ['ans'] ==
                //                                   'a'
                //                               ? Colors.green
                //                               : AppTheme.color757575,
                //                         ),
                //                         borderRadius: const BorderRadius.all(
                //                             const Radius.circular(2.0)),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //                   child: SizedBox(
                //                     width: devWidth - 80,
                //                     child: Html(
                //                       data:
                //                           "<p>${questionMap[questionMap.keys.elementAt(index)]['a']}</p>",
                //                       style: {
                //                         "p": Style(
                //                             color: questionMap[questionMap
                //                                             .keys
                //                                             .elementAt(index)]
                //                                         ['ans'] ==
                //                                     'a'
                //                                 ? Colors.green
                //                                 : AppTheme.color757575,
                //                             fontSize: FontSize(18)),
                //                       },
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Divider(),
                //           Row(
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.only(left: 20),
                //                 child: Column(
                //                   children: [
                //                     Container(
                //                       height: 35.0,
                //                       width: 35.0,
                //                       child: Center(
                //                         child: Text('B',
                //                             style: TextStyle(
                //                                 color: questionMap[questionMap
                //                                                 .keys
                //                                                 .elementAt(
                //                                                     index)]
                //                                             ['ans'] ==
                //                                         'b'
                //                                     ? Colors.green
                //                                     : AppTheme.color757575,
                //                                 //fontWeight: FontWeight.bold,
                //                                 fontSize: 18.0)),
                //                       ),
                //                       decoration: BoxDecoration(
                //                         color: Colors.transparent,
                //                         border: Border.all(
                //                           width: 1.0,
                //                           color: questionMap[questionMap.keys
                //                                           .elementAt(index)]
                //                                       ['ans'] ==
                //                                   'b'
                //                               ? Colors.green
                //                               : AppTheme.color757575,
                //                         ),
                //                         borderRadius: const BorderRadius.all(
                //                             const Radius.circular(2.0)),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //                   child: SizedBox(
                //                     width: devWidth - 80,
                //                     child: Html(
                //                       data:
                //                           "<p>${questionMap[questionMap.keys.elementAt(index)]['b']}</p>",
                //                       style: {
                //                         "p": Style(
                //                             color: questionMap[questionMap
                //                                             .keys
                //                                             .elementAt(index)]
                //                                         ['ans'] ==
                //                                     'b'
                //                                 ? Colors.green
                //                                 : AppTheme.color757575,
                //                             fontSize: FontSize(18)),
                //                       },
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Divider(),
                //           Row(
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.only(left: 20),
                //                 child: Column(
                //                   children: [
                //                     Container(
                //                       height: 35.0,
                //                       width: 35.0,
                //                       child: Center(
                //                         child: Text('C',
                //                             style: TextStyle(
                //                                 color: questionMap[questionMap
                //                                                 .keys
                //                                                 .elementAt(
                //                                                     index)]
                //                                             ['ans'] ==
                //                                         'c'
                //                                     ? Colors.green
                //                                     : AppTheme.color757575,
                //                                 //fontWeight: FontWeight.bold,
                //                                 fontSize: 18.0)),
                //                       ),
                //                       decoration: BoxDecoration(
                //                         color: Colors.transparent,
                //                         border: Border.all(
                //                           width: 1.0,
                //                           color: questionMap[questionMap.keys
                //                                           .elementAt(index)]
                //                                       ['ans'] ==
                //                                   'c'
                //                               ? Colors.green
                //                               : AppTheme.color757575,
                //                         ),
                //                         borderRadius: const BorderRadius.all(
                //                             const Radius.circular(2.0)),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //                   child: SizedBox(
                //                     width: devWidth - 80,
                //                     child: Html(
                //                       data:
                //                           "<p>${questionMap[questionMap.keys.elementAt(index)]['c']}</p>",
                //                       style: {
                //                         "p": Style(
                //                             color: questionMap[questionMap
                //                                             .keys
                //                                             .elementAt(index)]
                //                                         ['ans'] ==
                //                                     'c'
                //                                 ? Colors.green
                //                                 : AppTheme.color757575,
                //                             fontSize: FontSize(18)),
                //                       },
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Divider(),
                //           Row(
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.only(left: 20),
                //                 child: Column(
                //                   children: [
                //                     Container(
                //                       height: 35.0,
                //                       width: 35.0,
                //                       child: Center(
                //                         child: Text('D',
                //                             style: TextStyle(
                //                                 color: questionMap[questionMap
                //                                                 .keys
                //                                                 .elementAt(
                //                                                     index)]
                //                                             ['ans'] ==
                //                                         'd'
                //                                     ? Colors.green
                //                                     : AppTheme.color757575,
                //                                 //fontWeight: FontWeight.bold,
                //                                 fontSize: 18.0)),
                //                       ),
                //                       decoration: BoxDecoration(
                //                         color: Colors.transparent,
                //                         border: Border.all(
                //                           width: 1.0,
                //                           color: questionMap[questionMap.keys
                //                                           .elementAt(index)]
                //                                       ['ans'] ==
                //                                   'd'
                //                               ? Colors.green
                //                               : AppTheme.color757575,
                //                         ),
                //                         borderRadius: const BorderRadius.all(
                //                             const Radius.circular(2.0)),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //                   child: SizedBox(
                //                     width: devWidth - 80,
                //                     child: Html(
                //                       data:
                //                           "<p>${questionMap[questionMap.keys.elementAt(index)]['d']}</p>",
                //                       style: {
                //                         "p": Style(
                //                             color: questionMap[questionMap
                //                                             .keys
                //                                             .elementAt(index)]
                //                                         ['ans'] ==
                //                                     'd'
                //                                 ? Colors.green
                //                                 : AppTheme.color757575,
                //                             fontSize: FontSize(18)),
                //                       },
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               ElevatedButton(
                //                 onPressed: () {
                //                   showDialog(
                //                       context: context,
                //                       builder: (BuildContext context) {
                //                         return FeedbackDialogBox(
                //                           ques: questionMap[questionMap.keys
                //                               .elementAt(index)]['ques'],
                //                           examTitle: _examTitle,
                //                         );
                //                       });
                //                 },
                //                 child: Text("Send Feedback"),
                //                 style: ButtonStyle(
                //                   foregroundColor:
                //                       MaterialStateProperty.all<Color>(
                //                           AppTheme.white),
                //                   backgroundColor:
                //                       MaterialStateProperty.all<Color>(
                //                           AppTheme.color0081B9),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           SizedBox(
                //             height: 40,
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Send Feedback'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FeedbackDialogBox(examTitle: _examTitle);
            },
          );
        },
        backgroundColor: AppTheme.color0081B9,
        foregroundColor: AppTheme.white,
      ),
    );
  }
}
