// class RoomData {
//   final String id, name, question, answer, recommendation, recommendationThera;
//   int priority;
//   Map<String, dynamic> rooms;
//   Map<String, dynamic> questions;

//   RoomData(
//       {this.id,
//       this.name,
//       this.question,
//       this.answer,
//       this.priority,
//       this.recommendation,
//       this.recommendationThera});

//   Map<String, dynamic> toJson(index1, index2) => {
//         'roomCount': id,
//         'rooms': rooms,
//       };

//   roomItem(index, name, total, questions) {
//     [
//       {'name': name, 'total': total, 'question': questions}
//     ];
//   }

//   questionItem(
//       index, question, answer, priority, recommendation, recommendationThera) {
//     [
//       {
//         'question': question,
//         'answer': answer,
//         'priority': priority,
//         'recommendation': recommendation,
//         'recommendationThera': recommendationThera
//       }
//     ];
//   }
// }

class Question {
  final String question, answer, recommendation, recommendationThera;
  int priority;
  var id;
  Map<String, dynamic> rooms;
  Map<String, dynamic> que;

  Question(
      {this.id,
      this.question,
      this.answer,
      this.priority,
      this.recommendation,
      this.recommendationThera});

  static Question fromJson(Map<String, dynamic> json) => Question(
      question: json['question'],
      answer: json['answer'],
      priority: json['priority'],
      id: json['id'],
      recommendation: json['recommendation'],
      recommendationThera: json['recommendationThera']);

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'priority': priority,
        'id': id,
        'recommendation': recommendation,
        'recommendationThera': recommendationThera
      };
  // Map<String, dynamic> toJson(index1, index2) => {
  //       'roomCount': id,
  //       'rooms': rooms,
  //     };

  questionItem(
      index, question, answer, priority, recommendation, recommendationThera) {
    [
      {
        'question': question,
        'answer': answer,
        'priority': priority,
        'recommendation': recommendation,
        'recommendationThera': recommendationThera
      }
    ];
  }
}
