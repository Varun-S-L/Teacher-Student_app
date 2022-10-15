class ChatRoom {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;

  ChatRoom({this.chatroomid, this.participants, this.lastMessage});
  factory ChatRoom.fromMap(map) {
    return ChatRoom(
      chatroomid: map['chatroomid'],
      participants: map['participants'],
      lastMessage: map['lastmessage'],
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastmessage': lastMessage
    };
  }
}
