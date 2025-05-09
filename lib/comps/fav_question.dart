import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_html/flutter_html.dart';

class FavoriteQuestionScreen extends StatefulWidget {
  const FavoriteQuestionScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteQuestionScreen> createState() => _FavoriteQuestionScreenState();
}

class _FavoriteQuestionScreenState extends State<FavoriteQuestionScreen> {
  late Database db;
  var fav_list = [];
  List<Map<String, dynamic>> ques = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement initState
    super.didChangeDependencies();
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

    final List<Map<String, dynamic>> favs = await db.query('favorite');
    if (favs.length > 0) {
      favs.forEach((element) {
        fav_list.add(element['question']);
      });
      var fav_str = "id IN (";
      fav_list.forEach((element) {
        fav_str = fav_str + element.toString() + ", ";
      });
      fav_str = fav_str.substring(0, fav_str.length - 2);
      fav_str = fav_str + ")";

      ques = await db.query('question', where: fav_str);

      print(ques);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 255, 255, 255)),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 20,
                color: Color(0xff0081B9),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xffF2F5F8),
        title: const Center(
            child: Text(
          "El-Test",
          style: TextStyle(
            color: const Color(0xff21205A),
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
      backgroundColor: const Color(0xffF2F5F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: const Text(
                'Favorite Questions',
                style: const TextStyle(
                  color: Color(0xff21205A),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: ques.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Html(
                          data: "<p>Q: ${ques[index]['ques']}</p>",
                          style: {
                            "p": Style(
                                color: Color.fromARGB(255, 95, 95, 95),
                                fontSize: FontSize(18)),
                          },
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: SizedBox(
                                width: devWidth - 80,
                                child: Html(
                                  data: "<p>A: ${ques[index]['a']}</p>",
                                  style: {
                                    "p": Style(
                                        color: ques[index]['ans'] ==
                                              'a'
                                          ? Colors.green
                                          :Color.fromARGB(255, 95, 95, 95),
                                        fontSize: FontSize(18)),
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: SizedBox(
                                width: devWidth - 80,
                                child:
                                Html(
                                  data: "<p>B: ${ques[index]['b']}</p>",
                                  style: {
                                    "p": Style(
                                        color: ques[index]['ans'] ==
                                              'b'
                                          ? Colors.green
                                          :Color.fromARGB(255, 95, 95, 95),
                                        fontSize: FontSize(18)),
                                  },
                                ), 
                                
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: SizedBox(
                                width: devWidth - 80,
                                child: 
                                Html(
                                  data: "<p>C: ${ques[index]['c']}</p>",
                                  style: {
                                    "p": Style(
                                        color: ques[index]['ans'] ==
                                              'c'
                                          ? Colors.green
                                          :Color.fromARGB(255, 95, 95, 95),
                                        fontSize: FontSize(18)),
                                  },
                                ), 
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: SizedBox(
                                width: devWidth - 80,
                                child: Html(
                                  data: "<p>D: ${ques[index]['d']}</p>",
                                  style: {
                                    "p": Style(
                                        color: ques[index]['ans'] ==
                                              'd'
                                          ? Colors.green
                                          :Color.fromARGB(255, 95, 95, 95),
                                        fontSize: FontSize(18)),
                                  },
                                ), 
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
