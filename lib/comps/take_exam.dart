// ignore_for_file: prefer_const_constructors

import 'package:chapasdk/chapasdk.dart';
import 'package:eltest_exit/models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:eltest_exit/theme/app_theme.dart';

import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tex/flutter_tex.dart';

import 'service/common.dart';

class TakeExam extends StatefulWidget {
  const TakeExam({Key? key}) : super(key: key);

  @override
  State<TakeExam> createState() => _TakeExamState();
}

class _TakeExamState extends State<TakeExam> {
  List<QuestionModel> questions = [];
  List<RadioModel> questionData = <RadioModel>[];
  List<Result> result = [];
  List<ResultWrong> res_wrong = [];
  List<ResultTime> res_time = [];
  List<Favourite> res_fav = [];
  List<ResultChapter> res_chapter = [];
  int? _examId;
  String? _examTitle;
  int? _examTime;
  var isLoading = true;

  int ques_no = 0;

  var final_data = {};
  var chapter_count = {};
  var right_ans = [];
  var wrong_ans = {};
  var unans_ans = [];
  var fav_list = [];
  var ques_time = {};

  var c_time;
  var start_time;
  var end_time;

  final ScrollController cont1 = ScrollController();
  final ScrollController cont2 = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement initState
    super.didChangeDependencies();
    Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    _examId = arguments['exam_id'];
    _examTitle = arguments['title'];
    _examTime = arguments['time'];
    getData(_examId);
  }

  getData(exam_id) async {
    isLoading = false;
    questions.clear();
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");
    var db = await openDatabase(path, version: 1);
    final List<Map<String, dynamic>> maps = await db.query(
      'question',
      where: 'exam=${exam_id}',
    );

    List.generate(maps.length, (i) {
      questions.add(
        QuestionModel(
          maps[i]["id"],
          maps[i]["ques"],
          maps[i]["a"],
          maps[i]["b"],
          maps[i]["c"],
          maps[i]["d"],
          maps[i]["ans"],
          maps[i]["image"],
          maps[i]["chapter"],
        ),
      );
    });
    if (questions != []) {
      assignQues();
      setState(() {
        isLoading = true;
      });
      start_time = Duration(minutes: 120);
    }
  }

  assignQues() {
    questionData.clear();
    if (final_data[questions[ques_no].id] == null) {
      questionData.add(
        new RadioModel(false, 'A', '${questions[ques_no].choiceA}'),
      );
      questionData.add(
        new RadioModel(false, 'B', '${questions[ques_no].choiceB}'),
      );
      questionData.add(
        new RadioModel(false, 'C', '${questions[ques_no].choiceC}'),
      );
      questionData.add(
        new RadioModel(false, 'D', '${questions[ques_no].choiceD}'),
      );
    } else {
      questionData.add(
        new RadioModel(
          final_data[questions[ques_no].id] == 'A' ? true : false,
          'A',
          '${questions[ques_no].choiceA}',
        ),
      );
      questionData.add(
        new RadioModel(
          final_data[questions[ques_no].id] == 'B' ? true : false,
          'B',
          '${questions[ques_no].choiceB}',
        ),
      );
      questionData.add(
        new RadioModel(
          final_data[questions[ques_no].id] == 'C' ? true : false,
          'C',
          '${questions[ques_no].choiceC}',
        ),
      );
      questionData.add(
        new RadioModel(
          final_data[questions[ques_no].id] == 'D' ? true : false,
          'D',
          '${questions[ques_no].choiceD}',
        ),
      );
    }
  }

  getChapter(id) async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");
    var db = await openDatabase(path, version: 1);
    final List<Map<String, dynamic>> subchaps = await db.query(
      'subchapter',
      where: 'id=${id}',
    );

    return subchaps;
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Color(0xff0081B9),
          title: Center(child: Text('${_examTitle}')),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    fav_list.contains(questions[ques_no].id)
                        ? fav_list.remove(questions[ques_no].id)
                        : fav_list.add(questions[ques_no].id);
                  });
                },
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: Icon(
                    fav_list.contains(questions[ques_no].id)
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    size: 20,
                    color: AppTheme.red,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Visibility(
            visible: isLoading,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SlideCountdownSeparated(
                    onDone: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Time is UP',
                      )..show();
                      end_time = c_time;
                      ques_time[questions[ques_no].id] == null
                          ? ques_time[questions[ques_no].id] =
                              end_time - start_time
                          : ques_time[questions[ques_no].id] =
                              ques_time[questions[ques_no].id] +
                              (end_time - start_time);
                      Future.delayed(Duration(seconds: 2), () {
                        analyse();
                      });
                    },
                    onChanged: (value) {
                      c_time = value;
                    },
                    duration: Duration(minutes: _examTime!),
                    icon: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.alarm,
                        color: Color.fromARGB(255, 110, 52, 52),
                        size: 20,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  // TeXView(child: TeXViewColumn(children: ques_tex)),


                  // Padding(
                  //   padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  //   child: Center(
                  //     child: SizedBox(
                  //       height: 220,
                  //       child: Card(
                  //         color: Color(0xff0081B9),
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10)),
                  //         child: Container(
                  //           width: devWidth - 30,
                  //           height: 200,
                  //           child: Scrollbar(
                  //           thumbVisibility: true,
                  //           controller: cont1,
                  //           interactive: true,
                  //           thickness: 5,
                  //           radius: Radius.circular(20),
                  //           trackVisibility: true,
                  //             child: SingleChildScrollView(
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Padding(
                  //                     padding: const EdgeInsets.fromLTRB(
                  //                         15, 10, 15, 10),
                  //                     child: Text(
                  //                       'Question ${ques_no + 1}/${questions.length}',
                  //                       style: TextStyle(
                  //                           color: Color.fromARGB(
                  //                               255, 255, 255, 255),
                  //                           fontSize: 20,
                  //                           fontFamily: "Inter",
                  //                           fontWeight: FontWeight.bold),
                  //                     ),
                  //                   ),
                  //                   Padding(
                  //                     padding:
                  //                         EdgeInsets.fromLTRB(15, 10, 15, 10),
                  //                     child: Column(
                  //                       children: [
                  //                         Html(
                  //                           data:
                  //                               "<p>${questions[ques_no].ques}</p>",
                  //                           style: {
                  //                             "p": Style(
                  //                                 color: Color.fromARGB(
                  //                                     255, 255, 255, 255),
                  //                                 fontSize: FontSize(18)),
                  //                           },
                  //                         ),
                  //                         // Text(
                  //                         //   '${questions[ques_no].ques}',
                  //                         //   style: TextStyle(
                  //                         //     color: Color.fromARGB(
                  //                         //         255, 255, 255, 255),
                  //                         //     fontSize: 18,
                  //                         //     fontFamily: "Inter",
                  //                         //   ),
                  //                         // ),
                  //                         SizedBox(
                  //                           height: 10,
                  //                         ),
                  //                         SizedBox(
                  //                           height: 150,
                  //                           child: questions[ques_no].imageN !=
                  //                                   null
                  //                               ? Image.network(
                  //                                   '${main_url}${questions[ques_no].imageN}')
                  //                               : Text(''),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Scrollbar(
                  // thumbVisibility: true,
                  // controller: cont2,
                  // radius: Radius.circular(20),
                  // thickness: 5,
                  // trackVisibility: true,
                  // interactive: true,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(10),
                  //     child: SizedBox(
                  //       height: deviceHeight - 450,
                  //       width: devWidth - 30,
                  //       child: ListView.builder(
                  //         itemCount: questionData.length,
                  //         itemBuilder: (BuildContext context, int index) {
                  //           return InkWell(
                  //             //highlightColor: Colors.red,
                  //             splashColor: Color(0xff0081B9),
                  //             onTap: () {
                  //               setState(() {
                  //                 questionData.forEach(
                  //                     (element) => element.isSelected = false);
                  //                 questionData[index].isSelected = true;

                  //                 final_data[questions[ques_no].id] =
                  //                     questionData[index].buttonText;
                  //               });
                  //             },
                  //             child: Container(
                  //               margin: EdgeInsets.all(5),
                  //               child: Row(
                  //                 mainAxisSize: MainAxisSize.max,
                  //                 children: <Widget>[
                  //                   Container(
                  //                     height: 35.0,
                  //                     width: 35.0,
                  //                     child: Center(
                  //                       child: Text(
                  //                           questionData[index].buttonText,
                  //                           style: TextStyle(
                  //                               color: questionData[index]
                  //                                       .isSelected
                  //                                   ? Colors.white
                  //                                   : Color.fromARGB(
                  //                                       255, 117, 117, 117),
                  //                               //fontWeight: FontWeight.bold,
                  //                               fontSize: 18.0)),
                  //                     ),
                  //                     decoration: BoxDecoration(
                  //                       color: questionData[index].isSelected
                  //                           ? Color(0xff0081B9)
                  //                           : Colors.transparent,
                  //                       border: Border.all(
                  //                           width: 1.0,
                  //                           color:
                  //                               questionData[index].isSelected
                  //                                   ? Color(0xff0081B9)
                  //                                   : Color.fromARGB(
                  //                                       255, 117, 117, 117)),
                  //                       borderRadius: const BorderRadius.all(
                  //                           const Radius.circular(2.0)),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: devWidth - 110,
                  //                     child: Container(
                  //                       margin: EdgeInsets.only(left: 10.0),
                  //                       child: Html(
                  //                         data:
                  //                             "<p>${questionData[index].text}</p>",
                  //                         style: {
                  //                           "p": Style(
                  //                               color: questionData[index]
                  //                                       .isSelected
                  //                                   ? Color(0xff0081B9)
                  //                                   : Color.fromARGB(
                  //                                       255, 117, 117, 117),
                  //                               fontSize: FontSize(16)),
                  //                         },
                  //                       ),
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                end_time = c_time;
                ques_time[questions[ques_no].id] == null
                    ? ques_time[questions[ques_no].id] = end_time - start_time
                    : ques_time[questions[ques_no].id] =
                        ques_time[questions[ques_no].id] +
                        (end_time - start_time);
                setState(() {
                  ques_no > 0 ? ques_no-- : null;
                  assignQues();
                  start_time = c_time;
                });
              },
              child: Text('Prev.'),
              backgroundColor: Color(0xff0081B9),
              heroTag: 'mapZoomIn',
            ),
            FloatingActionButton(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.bottomSlide,
                  body: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        final_data.length < questions.length
                            ? Text(
                              'There are ${questions.length - final_data.length} Unanswered Questions',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            )
                            : Text(''),
                        SizedBox(height: 10),
                        Text(
                          'Your are going to finish the exam and get information about your score. Do you want to continue?',
                          style: TextStyle(
                            color: Color(0xff0081B9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  btnCancelOnPress: () {},
                  btnCancelText: 'Back',
                  btnOkText: 'Continue',
                  btnOkOnPress: () {
                    end_time = c_time;
                    ques_time[questions[ques_no].id] == null
                        ? ques_time[questions[ques_no].id] =
                            end_time - start_time
                        : ques_time[questions[ques_no].id] =
                            ques_time[questions[ques_no].id] +
                            (end_time - start_time);
                    analyse();
                  },
                )..show();
              },
              child: Text('End'),
              backgroundColor: Colors.green,
              heroTag: 'showUserLocation',
            ),
            FloatingActionButton(
              onPressed: () {
                end_time = c_time;
                ques_time[questions[ques_no].id] == null
                    ? ques_time[questions[ques_no].id] = end_time - start_time
                    : ques_time[questions[ques_no].id] =
                        ques_time[questions[ques_no].id] +
                        (end_time - start_time);
                setState(() {
                  ques_no < questions.length - 1 ? ques_no++ : null;
                  assignQues();
                  start_time = c_time;
                });
                print(fav_list);
              },
              child: Text('Next'),
              backgroundColor: Color(0xff0081B9),
              heroTag: 'mapGoToHome',
            ),
          ],
        ),
      ),
    );
  }

  analyse() {
    int? chapter;
    int? sc;
    chapter_count = {};
    for (var dt in final_data.keys) {
      questions.forEach((element) {
        element.id == dt ? chapter = element.chapter : null;
      });

      sc = chapter;

      if (chapter_count.keys.contains(sc)) {
        chapter_count[sc]['amount']++;
        questions.forEach((element) {
          element.id == dt
              ? final_data[dt].toLowerCase() == element.ans
                  ? chapter_count[sc]['right']++
                  : chapter_count[sc]['wrong']++
              : null;
        });
        chapter_count[sc]['time'].add(ques_time[dt]);
      } else {
        chapter_count[sc] = {};
        chapter_count[sc]['amount'] = 1;
        chapter_count[sc]['right'] = 0;
        chapter_count[sc]['wrong'] = 0;

        questions.forEach((element) {
          element.id == dt
              ? final_data[dt].toLowerCase() == element.ans
                  ? chapter_count[sc]['right']++
                  : chapter_count[sc]['wrong']++
              : null;
        });
        chapter_count[sc]['time'] = [];
        chapter_count[sc]['time'].add(ques_time[dt]);
      }
      questions.forEach((element) {
        element.id == dt
            ? final_data[dt].toLowerCase() == element.ans
                ? right_ans.add(dt)
                : wrong_ans[dt] = final_data[dt]
            : null;
      });

      final_data.keys.last == dt ? finalToDatabase() : null;
    }
  }

  finalToDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");
    var db = await openDatabase(path, version: 1);
    String rt = '0';
    String unans = '0';
    right_ans.forEach((element) {
      rt = rt + ',' + element.toString();
    });
    unans_ans.forEach((element) {
      unans = unans + ',' + element.toString();
    });

    var rs = Result(_examId!, rt, unans);

    var rs_ondb = await db.insert(
      'result',
      rs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final List<Map<String, dynamic>> dd = await db.query(
      'result',
      where: 'id=${rs_ondb}',
    );

    for (var wa in wrong_ans.keys) {
      var wr_ans = ResultWrong(wa, wrong_ans[wa]);
      wr_ans.setResult(dd[0]['id']);
      await db.insert(
        'resultwrong',
        wr_ans.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var rs in ques_time.keys) {
      var rs_t = ResultTime(rs, ques_time[rs].inSeconds.toString());
      rs_t.setResult(dd[0]['id']);
      await db.insert(
        'resulttime',
        rs_t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var chp in chapter_count.keys) {
      Duration avgt = Duration(seconds: 0);

      chapter_count[chp]['time'].forEach((elem) {
        avgt = avgt + elem;
      });

      var f_time = avgt.inSeconds.toInt() / chapter_count[chp]['time'].length;

      var chap = ResultChapter(
        chp,
        chapter_count[chp]['amount'],
        chapter_count[chp]['right'],
        chapter_count[chp]['wrong'],
        0,
        f_time.toString(),
      );

      chap.setResult(dd[0]['id']);

      await db.insert(
        'resultchapter',
        chap.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (int i = 0; i < fav_list.length; i++) {
      await db.insert('favorite', {'question': fav_list[i]});
    }

    final List<Map<String, dynamic>> cc = await db.query('resultchapter');
    print(cc);

    Navigator.pushNamed(
      context,
      '/result',
      arguments: {
        "result_id": dd[0]['id'],
        'title': _examTitle,
        'exam_id': _examId,
        'time': _examTime,
      },
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  RadioModel(this.isSelected, this.buttonText, this.text);
}
