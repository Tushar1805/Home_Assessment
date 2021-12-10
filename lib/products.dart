import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/productDetails.dart';

class Products extends StatelessWidget {
  List<Map<String, dynamic>> list = [
    {
      "room": "Living Arrangements",
      "question": [
        {
          "question": "Assistive Device",
          "products": [
            {"name": "SC/Quad", "description": "", "url": ""},
            {"name": "Cane/Std", "description": "", "url": ""},
            {
              "name": "Walker",
              "description":
                  "A walker is a type of mobility aid used to help people who are still able to walk (e.g., don't require a wheelchair) yet need assistance.\n\nIt is a four-legged frame that allows a person to lean on it for balance, support, and rest. \n\nWalkers are usually made out of aluminum so they are light enough to be picked up and moved easily. \n\nThey often have comfort grips made of foam, gel, or rubber to enhance the user's comfort. The tips of the legs are typically covered with rubber caps that are designed to prevent slipping and improve stability.",
              "url":
                  "https://www.aafp.org/afp/2011/0815/hi-res/afp20110815p405-f6.jpg"
            },
            {
              "name": "Front Wheel Walker",
              "description":
                  "The greatest benefit to using a front wheel walker is increased mobility.\n\nWith wheels on the front end, you don’t have to lift the walker every time you take a step. If you don’t have the upper body strength or endurance to use a basic walker comfortably, a wheeled option can still provide balance but makes movement easier.\n\nYou can move faster with a front wheel walker, but it’s still grounded by the two back legs. Many products offer slip-resistant caps or glide caps for the rear legs.\n\nSlip-resistant caps are made of a material like rubber, which prevents the walker from slipping on smooth surfaces. Glide caps, or glides, help a walker move more smoothly and quickly across a surface.",
              "url":
                  "https://5.imimg.com/data5/WJ/YH/BR/SELLER-66068728/front-wheel-walker-500x500.jpg"
            },
            {"name": "4 Whl. Walker", "description": "", "url": ""},
            {"name": "Manual Whl Chair", "description": "", "url": ""},
            {"name": "Power W/c", "description": "", "url": ""},
            {"name": "Crutches", "description": "", "url": ""},
            {"name": "Scooter", "description": "", "url": ""}
          ]
        }
      ]
    },
    {
      "room": "Pathway",
      "question": [],
    },
    {
      "room": "Living Room",
      "question": [
        {
          "question": "Switch Type",
          "products": [],
        },
      ],
    },
    {
      "room": "Kitchen",
      "question": [],
    },
    {
      "room": "Dining Room",
      "question": [],
    },
    {
      "room": "Bathroom",
      "question": [],
    },
    {
      "room": "Bedroom",
      "question": [],
    },
    {
      "room": "Laundry",
      "question": [],
    },
    {
      "room": "Patio",
      "question": [],
    },
    {
      "room": "Garage",
      "question": [],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        elevation: 0.0,
      ),
      body:
          // Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          // child:
          Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(15),
                  child: (list[index]["question"].length > 0)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Row(
                                children: [
                                  Text("${index + 1}. ",
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)),
                                  Text("${list[index]["room"]}",
                                      style: TextStyle(
                                          fontSize: 28,
                                          color: Color.fromRGBO(10, 80, 106, 1),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: ListView.builder(
                                    itemCount: list[index]["question"].length,
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index2) {
                                      return Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${list[index]["question"][index2]["question"]}",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: ListView.builder(
                                                  itemCount: list[index]
                                                              ["question"]
                                                          [index2]["products"]
                                                      .length,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index3) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => ProductDetails(
                                                                list[index]["question"][index2]
                                                                            ["products"]
                                                                        [index3]
                                                                    ['name'],
                                                                list[index]["question"]
                                                                            [index2]
                                                                        ["products"][index3]
                                                                    [
                                                                    'description'],
                                                                list[index]["question"]
                                                                            [index2]
                                                                        ["products"]
                                                                    [index3]['url'])));
                                                      },
                                                      child: Container(
                                                        child: Card(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  child: Card(
                                                                elevation: 0.0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7.0),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: (list[index]["question"][index2]["products"][index3]
                                                                              [
                                                                              'url'] !=
                                                                          "")
                                                                      ? CachedNetworkImage(
                                                                          imageUrl:
                                                                              list[index]["question"][index2]["products"][index3]['url'],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              40,
                                                                          height:
                                                                              40,
                                                                          placeholder: (context, url) =>
                                                                              new CircularProgressIndicator(),
                                                                          errorWidget: (context, url, error) =>
                                                                              new Icon(
                                                                            Icons.error,
                                                                            size:
                                                                                40,
                                                                          ),
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .image,
                                                                          size:
                                                                              40,
                                                                        ),
                                                                ),
                                                              )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  "${list[index]["question"][index2]["products"][index3]['name']}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ])
                      : SizedBox(),
                );
              }),
        ),
      ),
      // ),
    );
  }
}
