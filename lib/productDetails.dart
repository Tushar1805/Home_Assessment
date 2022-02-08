import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final String name;
  final String desc;
  final String url;
  const ProductDetails(this.name, this.desc, this.url, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name'),
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        elevation: 0.0,
      ),
      body: Container(
          constraints: BoxConstraints.expand(),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height *
                          0.4, // This is needed
                      child: (url != "")
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, url, error) => new Icon(
                                Icons.error,
                                size: 40,
                              ),
                            )
                          : Icon(
                              Icons.image,
                              size: 300,
                            ),
                    ),
                    // Positioned(
                    //   top: 220.0,
                    //   left: 15.0,
                    //   child: Container(
                    //       child: Text(
                    //     "$name",
                    //     style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 50,
                    //         fontWeight: FontWeight.bold),
                    //   )),
                    // ),
                    // Positioned(
                    //   top: 310,
                    //   left: 15,
                    //   right: 15,
                    //   child: Container(
                    //     child: Text(
                    //       "$desc",
                    //       style: TextStyle(fontSize: 18),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: MediaQuery.of(context).size.height * 0.47,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "$desc",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
