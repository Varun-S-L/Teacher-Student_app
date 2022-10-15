class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  DateTime? createdate;
  bool? seen;

  MessageModel(
      {this.messageid, this.sender, this.text, this.createdate, this.seen});
  factory MessageModel.fromMap(map) {
    return MessageModel(
      messageid: map['messageid'],
      sender: map['sender'],
      text: map['text'],
      createdate: map['createdate'].toDate(),
      seen: map['seen'],
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'messageid': messageid,
      'sender': sender,
      'text': text,
      'createdate': createdate,
      'seen': seen,
    };
  }
}
