import 'package:eltest_exit/comps/chapter_study.dart';
import 'package:eltest_exit/comps/entrance_study.dart';
import 'package:flutter/material.dart';

import 'model_study.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  Map<String, Widget> loc = {
    'entrance': EntranceStudyScreen(),
    'model': ModelStudyScreen(),
    'chapter': ChapterStudyScreen(),
  };

  String choosen = 'entrance';

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          choosen = 'entrance';
                        });
                      },
                      child: Card(
                        color: choosen == 'entrance'
                            ? Color(0xff0081B9)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: choosen == 'entrance'
                                            ? Colors.white
                                            : Color(0xff0081B9),
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.my_library_books_outlined,
                                        color: choosen == 'entrance'
                                            ? Color(0xff0081B9)
                                            : Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Entrance/Matric',
                                  style: TextStyle(
                                      color: choosen == 'entrance'
                                          ? Colors.white
                                          : Color(0xff0081B9),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          choosen = 'model';
                        });
                      },
                      child: Card(
                        color: choosen == 'model'
                            ? Color(0xff0081B9)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: choosen == 'model'
                                            ? Colors.white
                                            : Color(0xff0081B9),
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.my_library_books_outlined,
                                        color: choosen == 'model'
                                            ? Color(0xff0081B9)
                                            : Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Model',
                                  style: TextStyle(
                                    color: choosen == 'model'
                                        ? Colors.white
                                        : Color(0xff0081B9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          choosen = 'chapter';
                        });
                        
                      },
                      child: Card(
                        color: choosen == 'chapter'
                            ? Color(0xff0081B9)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: choosen == 'chapter'
                                            ? Colors.white
                                            : Color(0xff0081B9),
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.my_library_books_outlined,
                                        color: choosen == 'chapter'
                                            ? Color(0xff0081B9)
                                            : Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Chapter',
                                  style: TextStyle(
                                    color: choosen == 'chapter'
                                        ? Colors.white
                                        : Color(0xff0081B9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          loc[choosen]!,
        ],
      ),
    );
  }
}
