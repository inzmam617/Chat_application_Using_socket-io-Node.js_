import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String myUserId;
  final String otherUserId;
  final IO.Socket socket;

  ChatScreen({required this.myUserId, required this.otherUserId, required this.socket});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool isConnected = false;
  String roomId=" ";
  @override
  void initState() {
    super.initState();
    if (widget.myUserId.compareTo(widget.otherUserId) < 0) {
      roomId = '${widget.myUserId}${widget.otherUserId}';
    } else {
      roomId = '${widget.otherUserId}${widget.myUserId}';
    }
    widget.socket.emit('join', roomId );
    widget.socket.onConnect((data) {
      print('Connected to socket');
      isConnected = true;
    });
    widget.socket.onDisconnect((data) {
      print('Disconnected from socket');
      isConnected = false;
    });
    widget.socket.connect();
    widget.socket.on('message', _handleIncomingMessage);
  }

  @override
  void dispose() {
    widget.socket.off('message', _handleIncomingMessage);
    super.dispose();
  }

  void _handleIncomingMessage(data) {
    print("Data:${data}");
    setState(() {
      Map<String, String> message = {
        'senderId': widget.myUserId,
        'receiverId': widget.otherUserId,
        'text': data['text'].toString(),
      };
      _messages.add(message);
    });
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isNotEmpty&&isConnected==true) {
      Map<String, String> message = {
        'senderId': widget.myUserId,
        'receiverId': widget.otherUserId,
        'text': text,
        'roomId':roomId
      };
      print(message);
      widget.socket.emit('message', message);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                Map<String, String> message = _messages[index];
                bool isMe = message['senderId'] == widget.myUserId;
                return ListTile(
                  title: Text(message['text'].toString()),
                  subtitle: Text(isMe ? 'You' : widget.otherUserId),
                  trailing: isMe ? null : Icon(Icons.person),
                  tileColor: isMe ? Colors.blue[100] : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
