part of 'generated.dart';

class ListRoutesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListRoutesVariablesBuilder(this._dataConnect, );
  Deserializer<ListRoutesData> dataDeserializer = (dynamic json)  => ListRoutesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListRoutesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListRoutesData, void> ref() {
    
    return _dataConnect.query("ListRoutes", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListRoutesRoutes {
  final String id;
  final String name;
  final String description;
  final Timestamp startTime;
  final Timestamp endTime;
  ListRoutesRoutes.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  description = nativeFromJson<String>(json['description']),
  startTime = Timestamp.fromJson(json['startTime']),
  endTime = Timestamp.fromJson(json['endTime']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRoutesRoutes otherTyped = other as ListRoutesRoutes;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    description == otherTyped.description && 
    startTime == otherTyped.startTime && 
    endTime == otherTyped.endTime;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, description.hashCode, startTime.hashCode, endTime.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['description'] = nativeToJson<String>(description);
    json['startTime'] = startTime.toJson();
    json['endTime'] = endTime.toJson();
    return json;
  }

  ListRoutesRoutes({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
  });
}

@immutable
class ListRoutesData {
  final List<ListRoutesRoutes> routes;
  ListRoutesData.fromJson(dynamic json):
  
  routes = (json['routes'] as List<dynamic>)
        .map((e) => ListRoutesRoutes.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRoutesData otherTyped = other as ListRoutesData;
    return routes == otherTyped.routes;
    
  }
  @override
  int get hashCode => routes.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['routes'] = routes.map((e) => e.toJson()).toList();
    return json;
  }

  ListRoutesData({
    required this.routes,
  });
}

