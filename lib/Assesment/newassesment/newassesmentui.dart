import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentsbase.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentspro.dart';
// import 'package:tryapp/Assesment/assesmentpro.dart';
import 'newassesmentpro.dart';
import 'cardsUI.dart';
import 'package:provider/provider.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class NewAssesmentUI extends StatefulWidget {
  @override
  _NewAssesmentUIState createState() => _NewAssesmentUIState();
}

class _NewAssesmentUIState extends State<NewAssesmentUI> {
  @override
  Widget build(BuildContext context) {
    final assesmentprovider = Provider.of<NewAssesmentProvider>(context);
    return WillPopScope(
      onWillPop: () {
        showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Alert'),
                content: Text('Want to exit?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OldAssessments()),
                        (Route<dynamic> route) => false,
                      );

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => OldAssessments()));
                    },
                    child: Text('Go It'),
                  ),
                ],
              ),
            );
          },
        );
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assessment'),
          backgroundColor: _colorgreen,
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    width: double.infinity,
                    child: Text(
                      'Areas of Home Available:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 30,
                          color: _colorgreen,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 10000,
                          minHeight: MediaQuery.of(context).size.height / 10),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: assesmentprovider.getlistdata().length,
                        itemBuilder: (context, index) {
                          if (assesmentprovider.getlistdata()[index]['name'] ==
                              'Living Arrangements') {
                            return SizedBox(height: 0);
                          } else {
                            return roomOuterCard(assesmentprovider, index);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(15),
                      child: ClipOval(
                        child: Material(
                          color: Colors.orange, // button color
                          child: InkWell(
                            splashColor:
                                Color.fromRGBO(10, 80, 106, 1), // inkwell color
                            child: SizedBox(
                                width: 76,
                                height: 76,
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.white)),
                            onTap: () {
                              assesmentprovider.setassessmainstatus();
                              for (int i = 0;
                                  i < assesmentprovider.listofRooms.length;
                                  i++) {
                                if (assesmentprovider.listofRooms[i]['name'] ==
                                    'Living Arrangements') {
                                  setState(() {
                                    assesmentprovider.listofRooms[i]
                                        ['room$i'] = {
                                      'name':
                                          '${assesmentprovider.listofRooms[i]['name']}',
                                      'complete': 0,
                                      'total': gettotal(assesmentprovider
                                          .getlistdata()[i]['name']),
                                      'question': getMaps(assesmentprovider
                                          .getlistdata()[i]['name']),
                                    };
                                  });
                                }
                              }

                              // print(assesmentprovider.getlistdata());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CardsUINew(
                                          assesmentprovider.getlistdata())));
                              // Text('Karan')));
                              // print(assesmentprovider.listofRooms);
                            },
                          ),
                        ),
                      ))
                ],
              )),
        ),
      ),
    );
  }

  Widget roomOuterCard(NewAssesmentProvider prov, int index) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 5),
      elevation: 8,
      child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Text(
                    "${prov.getlistdata()[index]['name']}:",
                    style: TextStyle(
                        color: _colorgreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Number of ${prov.getlistdata()[index]['name']}: (?)",
                              style:
                                  TextStyle(fontSize: 15, color: _colorgreen),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: NumericStepButton(
                              maxValue: 20,
                              onChanged: (text) {
                                setState(
                                  () {
                                    // roomdata['count'] = text;
                                    if (text > 0) {
                                      //   widget.count = int.parse(text.toString());
                                      //   widget.obstacle = true;
                                      //

                                      prov.listofRooms[index]['count'] = text;
                                      prov.listofRooms[index]['room$text'] = {
                                        'name':
                                            '${prov.listofRooms[index]['name']} $text',
                                        'complete': 0,
                                        'total': gettotal(
                                            prov.getlistdata()[index]['name']),
                                        'question': getMaps(
                                            prov.getlistdata()[index]['name']),
                                      };

                                      if (prov.listofRooms[index].containsKey(
                                          'room${prov.listofRooms[index]['count'] + 1}')) {
                                        prov.listofRooms[index].remove(
                                            'room${prov.listofRooms[index]['count'] + 1}');
                                      }
                                    } else if (text.toString().length == 0 ||
                                        text == 0) {
                                      if (prov.listofRooms[index].containsKey(
                                          'room${prov.listofRooms[text]['count']}')) {
                                        prov.listofRooms[index].remove(
                                            'room${prov.listofRooms[text]['count']}');
                                      }
                                      prov.listofRooms[index]['count'] = text;
                                      // widget.obstacle = false;

                                    }
                                    // print(prov.listofRooms[index]);
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                      (prov.listofRooms[index]['count'] > 0)
                          ? Container(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: 1000,
                                      minHeight:
                                          MediaQuery.of(context).size.height /
                                              10),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: prov.listofRooms[index]['count'],
                                    itemBuilder: (context, index1) {
                                      return TextFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                '${prov.getlistdata()[index]['name']} (Name)'),
                                        onChanged: (text) {
                                          prov.listofRooms[index]
                                                  ['room${index1 + 1}']
                                              ['name'] = capitalize(text);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  )),
            ],
          )),
    );
  }
}

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key key, this.minValue = 0, this.maxValue = 10, this.onChanged})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Colors.green,
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
          ),
          Container(
            // width: 20,
            decoration: BoxDecoration(
                border: Border(
              bottom:
                  BorderSide(width: 1.0, color: Color.fromRGBO(10, 80, 106, 1)),
            )),
            child: Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
              });
            },
          ),
        ],
      ),
    );
  }
}
