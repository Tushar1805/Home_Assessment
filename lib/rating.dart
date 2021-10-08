import 'package:flutter/material.dart';

typedef void RatingChangeCallback(int rating);

class StarRating extends StatefulWidget {
  final int starCount;
  final int rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final double iconSize;
  const StarRating(
      {Key key,
      this.starCount = 5,
      this.rating,
      @required this.onRatingChanged,
      @required this.color,
      this.iconSize = 20.0})
      : super(key: key);

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= widget.rating) {
      icon = new Icon(
        Icons.star_border,
        // ignore: deprecated_member_use
        color: Theme.of(context).buttonColor,
        size: widget.iconSize,
      );
    } else if (index > widget.rating - 1 && index < widget.rating) {
      icon = new Icon(
        Icons.star_half,
        color: Color(0xffffbb20),
        size: widget.iconSize,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: Color(0xffffbb20),
        size: widget.iconSize,
      );
    }
    return new InkResponse(
      onTap:
          // ignore: unnecessary_null_comparison
          widget.onRatingChanged == null
              ? null
              : () => widget.onRatingChanged(index + 1),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: new List.generate(
            widget.starCount, (index) => buildStar(context, index)));
  }
}

// class StarRating extends StatelessWidget {
//   final int starCount;
//   final int rating;
//   final RatingChangeCallback onRatingChanged;
//   final Color color;
//   final double iconSize;

//   StarRating(
//       {this.starCount = 5,
//       this.rating,
//       @required this.onRatingChanged,
//       @required this.color,
//       this.iconSize = 20.0});

//   Widget buildStar(BuildContext context, int index) {
//     Icon icon;
//     if (index >= rating) {
//       icon = new Icon(
//         Icons.star_border,
//         // ignore: deprecated_member_use
//         color: Theme.of(context).buttonColor,
//         size: iconSize,
//       );
//     } else if (index > rating - 1 && index < rating) {
//       icon = new Icon(
//         Icons.star_half,
//         color: Color(0xffffbb20),
//         size: iconSize,
//       );
//     } else {
//       icon = new Icon(
//         Icons.star,
//         color: Color(0xffffbb20),
//         size: iconSize,
//       );
//     }
//     return new InkResponse(
//       onTap:
//           // ignore: unnecessary_null_comparison
//           onRatingChanged == null ? null : () => onRatingChanged(index + 1),
//       child: icon,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children:
//             new List.generate(starCount, (index) => buildStar(context, index)));
//   }
// }
