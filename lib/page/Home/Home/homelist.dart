import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/page/Home/Detail/detailPage.dart';
import 'package:cesa100/page/Home/Home/petlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeList extends StatefulWidget {
  const HomeList({super.key});

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  String query = '';
  List<petRowData> _dataLens = dataLens;

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
    print(query);
  }

  @override
  void initState() {
    super.initState();
    sortData();
  }

  void sortData(){
    _dataLens.sort((a, b) {
      if (a.bloodSugar > 200 || a.temperature > 40) {
        return -1;
      }
      else if (b.bloodSugar > 200 || b.temperature > 40) {
        return 1;
      }
      else {
        return 0;
      }
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _dataLens.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      splashFactory: NoSplash.splashFactory,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(width * 1, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Image(
                                  image: AssetImage(_dataLens[index].src),
                                  fit: BoxFit.scaleDown,
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                  '${dataLens[index].number}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/home/sugar-blood-level.png'),
                                  fit: BoxFit.scaleDown,
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                  '${dataLens[index].bloodSugar}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/home/temperature.png'),
                                  fit: BoxFit.scaleDown,
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                  '${dataLens[index].temperature}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      ],
                    )
                    // Text(
                    //   '${dataLens[index].number}',
                    // ),
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
