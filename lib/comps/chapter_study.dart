import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_theme.dart';
import '../models/exam_model.dart';

class ChapterStudyScreen extends StatefulWidget {
  const ChapterStudyScreen({Key? key}) : super(key: key);

  @override
  State<ChapterStudyScreen> createState() => _ChapterStudyScreenState();
}

class _ChapterStudyScreenState extends State<ChapterStudyScreen> {
  late Database db;
  bool isLoading = true;
  List<SubjectModel> subjects = [];
  List<Map<String, dynamic>> subs = [];
  List<Map<String, dynamic>> maps = [];

  int? subId;
  List st_cls = [
    [AppTheme.colorE1E9F9, AppTheme.color0081B9, AppTheme.color005275],
    [AppTheme.colorFDF1D9, AppTheme.colorF0A714, AppTheme.colorB27C0E],
    [AppTheme.colorFDE4E4, AppTheme.colorF35555, AppTheme.color9B1B1B],
    [AppTheme.colorDDF0E6, AppTheme.color28A164, AppTheme.color186F44],
  ];

  @override
  void initState() {
    super.initState();

    dbstat();
  }

  dbstat() async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");

    // open the database
    db = await openDatabase(
      path,
      version: 1,
    );

    final List<Map<String, dynamic>> favs = await db.query('favoriteexam');

    subs = await db.query('subject');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List.generate(subs.length, (i) {
        subs[i]['name'] == 'Amharic'
            ? null
            : subs[i]['name'] == 'General Business'
                ? null
                : subjects.add(
                    SubjectModel(
                      subs[i]['id'],
                      subs[i]['name'],
                    ),
                  );
    });

    setState(() {
      isLoading = true;
    });
  }

  checkChaps() async {
    setState(() {
      isLoading = false;
    });
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");

    // open the database
    db = await openDatabase(
      path,
      version: 1,
    );
    print(subId);

    maps = await db.query('chapter', where: "subject=${subId}");

    print(maps);

    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Subject Filter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: subjects.map((sub) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        subId = sub.id;
                        checkChaps();
                      });
                    },
                    child: Card(
                      color: subId == sub.id
                          ? AppTheme.color0081B9
                          : AppTheme.white,
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
                                      color: subId == sub.id
                                          ? AppTheme.white
                                          : AppTheme.color0081B9,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      color: subId == sub.id
                                          ? AppTheme.color0081B9
                                          : AppTheme.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${sub.name}',
                                style: TextStyle(
                                  color: subId == sub.id
                                      ? AppTheme.white
                                      : AppTheme.color0081B9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Visibility(
            visible: subId != null,
            child: ListView.builder(
              itemCount: maps.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Card(
                    color: st_cls[index % 4][0],
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.folder,
                              color: st_cls[index % 4][1],
                              size: 30,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${maps[index]['unit']}",
                                  style: TextStyle(
                                    color: st_cls[index % 4][2],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${maps[index]['name']}",
                                  style: TextStyle(
                                    color: st_cls[index % 4][1],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/take-chapt',
                                        arguments: {
                                          "chapter_id": maps[index]['id'],
                                          'title': maps[index]['name'],
                                        });
                                  },
                                  icon: Icon(
                                    Icons.arrow_circle_right_outlined,
                                    color: st_cls[index % 4][1],
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
