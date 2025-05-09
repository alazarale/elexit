import 'package:eltest_exit/comps/service/remote_services.dart';
import 'package:eltest_exit/models/store_national.dart';
import 'package:eltest_exit/models/subject_model.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../models/store_exam_model.dart';
import '../custom_dialog.dart';
import '../provider/auth.dart';
import '../service/download.dart';

class StoreNational extends StatefulWidget {
  const StoreNational({super.key});

  @override
  State<StoreNational> createState() => _StoreNationalState();
}

class _StoreNationalState extends State<StoreNational> {
  List<National>? nationals = [];
  bool isLoading = true;

  List<StoreExamModel>? store_exam;
  List code = [];
  String? _payRefId = '0';
  String? _payRef;
  late Database db;
  String? chosen_sub;
  String? isSubsc;
  String? _token;

  List st_cls = [
    [
      const Color(0xffE1E9F9),
      const Color(0xff0081B9),
      const Color.fromARGB(255, 0, 82, 117),
    ],
    [
      const Color(0xffFDF1D9),
      const Color(0xffF0A714),
      const Color.fromARGB(255, 178, 124, 14),
    ],
    [
      const Color(0xffFDE4E4),
      const Color(0xffF35555),
      const Color.fromARGB(255, 155, 27, 27),
    ],
    [
      const Color(0xffDDF0E6),
      const Color(0xff28A164),
      const Color.fromARGB(255, 24, 111, 68),
    ],
  ];

  @override
  void initState() {
    isSubsc = Provider.of<Auth>(context, listen: false).is_payed;
    _token = Provider.of<Auth>(context, listen: false).token;
    dbstat();
    getData();

    // This widget is the root of your application.
  }

  getData() async {
    print('sdf');
    isLoading = false;
    nationals = await NationalListFetch().get_nationals();
    if (nationals != null) {
      print(nationals);
      setState(() {
        isLoading = true;
      });
    }
  }

  dbstat() async {
    var databasesPath = await getDatabasesPath();
    var path = Path.join(databasesPath, "data_init.db");

    db = await openDatabase(path, version: 1);
    List<Map<String, dynamic>> maps = await db.query('exam');
    maps = List.from(maps.reversed);
    List.generate(maps.length, (i) {
      code.add(maps[i]['code']);
    });
    print(code);
    setState(() {});
  }

  getBySubject(sub_name, sub_id) async {
    isLoading = false;
    store_exam = await ExamsSearchFetch().getExams(sub_name, sub_id.toString());

    if (store_exam != null) {
      print(store_exam);
      store_exam!.removeWhere(
        (item) => code.contains('cd${item.id.toString()}'),
      );
      setState(() {
        store_exam;
        isLoading = true;
      });
    }
  }

  downloadIfSubsc(ex_id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // The loading indicator
                CircularProgressIndicator(),
                SizedBox(height: 15),
                // Some text
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
    SubscDownloadExam(ex_id, _token!, context).getQuestions().then((value) {
      Navigator.of(context).pop();
      Navigator.popAndPushNamed(context, "/");
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
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
            "Store",
            style: TextStyle(
              color: const Color(0xff21205A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xffF2F5F8),
      body: SingleChildScrollView(
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/paid',
                            arguments: {'where': 'all'},
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff0081B9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.library_books_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'All',
                                    style: TextStyle(
                                      color: Color(0xff0081B9),
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Color(0xff0081B9),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.menu_book_sharp,
                                          color: Color(0xff0081B9),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'National',
                                    style: TextStyle(
                                      color: Colors.white,
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/store-sub',
                            arguments: {'where': 'all'},
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff0081B9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.menu_book_sharp,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Uni/Collage',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 126, 126, 126),
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/store-sub',
                            arguments: {'where': 'all'},
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff0081B9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.menu_book_sharp,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'School',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 126, 126, 126),
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

                    //         Padding(
                    //           padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    //           child: GestureDetector(
                    //             onTap: () {

                    //             },
                    //             child: Card(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20.0),
                    //               ),
                    //               color: Color(0xff0081B9),
                    //               elevation: 0,
                    //               child: Padding(
                    //                 padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                    //                 child: Center(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     children: [
                    //                       Padding(
                    //                         padding: const EdgeInsets.only(right: 5),
                    //                         child: Container(
                    //                           decoration: BoxDecoration(
                    //                               color: Color.fromARGB(
                    //                                   255, 255, 255, 255),
                    //                               shape: BoxShape.circle),
                    //                           child: Padding(
                    //                             padding: const EdgeInsets.all(6.0),
                    //                             child: Icon(
                    //                               Icons.menu_book_sharp,
                    //                               color: Color(0xff0081B9),
                    //                               size: 18,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       const Text(
                    //                         'Subject',
                    //                         style: TextStyle(
                    //                           color: Color.fromARGB(255, 255, 255, 255),
                    //                           fontWeight: FontWeight.bold,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               Navigator.pushNamed(context, '/store-stream',
                    //                   arguments: {'where': 'all'});
                    //             },
                    //             child: Card(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20.0),
                    //               ),
                    //               elevation: 0,
                    //               child: Padding(
                    //                 padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                    //                 child: Center(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     children: [
                    //                       Padding(
                    //                         padding: const EdgeInsets.only(right: 5),
                    //                         child: Container(
                    //                           decoration: BoxDecoration(
                    //                               color: Color(0xff0081B9),
                    //                               shape: BoxShape.circle),
                    //                           child: Padding(
                    //                             padding: const EdgeInsets.all(6.0),
                    //                             child: Icon(
                    //                               Icons.type_specimen,
                    //                               color: Colors.white,
                    //                               size: 18,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       const Text(
                    //                         'Stream',
                    //                         style: TextStyle(
                    //                           color: Color.fromARGB(255, 126, 126, 126),
                    //                           fontWeight: FontWeight.bold,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: nationals?.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff0081B9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.book_online,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${nationals?[index].name}',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 126, 126, 126),
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
