import 'dart:async';
import 'package:chatclient/main.dart';
import 'package:chatclient/utils/viewModel/viewModel.dart';
import 'package:chatclient/utils/viewModel/viewModelProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:signalr_client/signalr_client.dart';

typedef HubConnectionProvider = Future<HubConnection> Function();

class ChatMessage {
  // Properites

  final String senderName;
  final String message;

  // Methods
  ChatMessage(this.senderName, this.message);
}

class ChatPageViewModel extends ViewModel {
// Properties
  String _serverUrl;
  HubConnection _hubConnection;

  List<ChatMessage> _chatMessages;
  static const String chatMessagesPropName = "chatMessages";
  List<ChatMessage> get chatMessages => _chatMessages;

  bool _connectionIsOpen;
  static const String connectionIsOpenPropName = "connectionIsOpen";
  bool get connectionIsOpen => _connectionIsOpen;
  set connectionIsOpen(bool value) {
    updateValue(connectionIsOpenPropName, _connectionIsOpen, value, (v) => _connectionIsOpen = v);
  }

  String _userName;
  static const String userNamePropName = "userName";
  String get userName => _userName;
  set userName(String value) {
    updateValue(userNamePropName, _userName, value, (v) => _userName = v);
  }

// Methods

  ChatPageViewModel() {
    _serverUrl = kChatServerUrl;
    _chatMessages = List<ChatMessage>();
    _connectionIsOpen = false;
    _userName = "Fred";

    openChatConnection();
  }

  Future<void> openChatConnection() async {
    if (_hubConnection == null) {
      _hubConnection = HubConnectionBuilder().withUrl(_serverUrl).build();
      _hubConnection.onclose((error) => connectionIsOpen = false);
      _hubConnection.on("UpdateLocation", _handleIncommingChatMessage);
    }

    if (_hubConnection.state != HubConnectionState.Connected) {
      await _hubConnection.start();
      print("Verificar ${_hubConnection.state}");
      connectionIsOpen = true;
    }
  }

  Future<void> sendChatMessage(String chatMessage) async {

    var message = new MasterLocationCreateModel();
    
    var model = message.toJson();

    print(model);

    await openChatConnection();
    
    _hubConnection.invoke("SaveLocation", args: <Object>[message.toJson()]);
  }

  void _handleIncommingChatMessage(List<Object> args){
    final String senderName = args[0];
    final String message = args[1];
    _chatMessages.add( ChatMessage(senderName, message));
    notifyPropertyChanged(chatMessagesPropName);
  }
}

class ChatPageViewModelProvider extends ViewModelProvider<ChatPageViewModel> {
  // Properties

  // Methods
  ChatPageViewModelProvider({Key key, viewModel: ChatPageViewModel, WidgetBuilder childBuilder}) : super(key: key, viewModel: viewModel, childBuilder: childBuilder);

  static ChatPageViewModel of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ChatPageViewModelProvider) as ChatPageViewModelProvider).viewModel;
  }
}


class MasterLocationCreateModel {
  String entityFK = 'ca033d48-9893-446d-81b3-25587da47d87';
  String societyFK = '85878cf1-a91e-4ab5-9430-8750b41478c5';
  String entityTypeFK = '8E37B279-F52F-4AB6-A363-6E559B5866F3';
  Coordinate coordinate = new Coordinate();
  String createdBy = 'ca033d48-9893-446d-81b3-25587da47d87';
  bool isActive = true;
  bool isDeleted = false;
  DateTime createdDate;

  MasterLocationCreateModel();

  MasterLocationCreateModel.fromJson(Map<String,dynamic> jsonMap)
    :entityFK = jsonMap['entityFK'],
    societyFK = jsonMap['societyFK'],
    entityTypeFK = jsonMap['entityTypeFK'],
    coordinate = jsonMap['coordinate'] != null ? Coordinate.fromJson(jsonMap['coordinate']) : new Coordinate(),
    createdBy = jsonMap['createdBy'],
    isActive = jsonMap['isActive'],
    isDeleted = jsonMap['isDeleted'],
    createdDate = jsonMap['createdDate'];

  Map<String, dynamic> toJson() {
    return{
      "entityFK" : entityFK,
      "societyFK" : societyFK,
      "entityTypeFK" : entityTypeFK,
      "coordinate" : coordinate.toJson(),
      "createdBy" : createdBy,
      "isActive" : isActive,
      "isDeleted" : isDeleted,
      "createdDate" : createdDate
    };
  }
}

class Coordinate {
  double x = -66.9614527723137;
  double y = 10.504493799067891;

  Coordinate();

  Coordinate.fromJson(Map<String,dynamic> jsonMap) 
    :y = jsonMap['y'],
    x = jsonMap['x'];

  Map<String, dynamic> toJson() {
    return {
      "y" : y,
      "x" : x
    };
  }
}