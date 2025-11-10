part of 'generated.dart';

class GetBusAssignmentForDriverVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetBusAssignmentForDriverVariablesBuilder(this._dataConnect, );
  Deserializer<GetBusAssignmentForDriverData> dataDeserializer = (dynamic json)  => GetBusAssignmentForDriverData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetBusAssignmentForDriverData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetBusAssignmentForDriverData, void> ref() {
    
    return _dataConnect.query("GetBusAssignmentForDriver", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetBusAssignmentForDriverBusAssignments {
  final String id;
  final GetBusAssignmentForDriverBusAssignmentsBus bus;
  final GetBusAssignmentForDriverBusAssignmentsRoute route;
  final DateTime assignmentDate;
  GetBusAssignmentForDriverBusAssignments.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  bus = GetBusAssignmentForDriverBusAssignmentsBus.fromJson(json['bus']),
  route = GetBusAssignmentForDriverBusAssignmentsRoute.fromJson(json['route']),
  assignmentDate = nativeFromJson<DateTime>(json['assignmentDate']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBusAssignmentForDriverBusAssignments otherTyped = other as GetBusAssignmentForDriverBusAssignments;
    return id == otherTyped.id && 
    bus == otherTyped.bus && 
    route == otherTyped.route && 
    assignmentDate == otherTyped.assignmentDate;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, bus.hashCode, route.hashCode, assignmentDate.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['bus'] = bus.toJson();
    json['route'] = route.toJson();
    json['assignmentDate'] = nativeToJson<DateTime>(assignmentDate);
    return json;
  }

  GetBusAssignmentForDriverBusAssignments({
    required this.id,
    required this.bus,
    required this.route,
    required this.assignmentDate,
  });
}

@immutable
class GetBusAssignmentForDriverBusAssignmentsBus {
  final String busNumber;
  final int capacity;
  GetBusAssignmentForDriverBusAssignmentsBus.fromJson(dynamic json):
  
  busNumber = nativeFromJson<String>(json['busNumber']),
  capacity = nativeFromJson<int>(json['capacity']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBusAssignmentForDriverBusAssignmentsBus otherTyped = other as GetBusAssignmentForDriverBusAssignmentsBus;
    return busNumber == otherTyped.busNumber && 
    capacity == otherTyped.capacity;
    
  }
  @override
  int get hashCode => Object.hashAll([busNumber.hashCode, capacity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['busNumber'] = nativeToJson<String>(busNumber);
    json['capacity'] = nativeToJson<int>(capacity);
    return json;
  }

  GetBusAssignmentForDriverBusAssignmentsBus({
    required this.busNumber,
    required this.capacity,
  });
}

@immutable
class GetBusAssignmentForDriverBusAssignmentsRoute {
  final String name;
  final String description;
  GetBusAssignmentForDriverBusAssignmentsRoute.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']),
  description = nativeFromJson<String>(json['description']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBusAssignmentForDriverBusAssignmentsRoute otherTyped = other as GetBusAssignmentForDriverBusAssignmentsRoute;
    return name == otherTyped.name && 
    description == otherTyped.description;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, description.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['description'] = nativeToJson<String>(description);
    return json;
  }

  GetBusAssignmentForDriverBusAssignmentsRoute({
    required this.name,
    required this.description,
  });
}

@immutable
class GetBusAssignmentForDriverData {
  final List<GetBusAssignmentForDriverBusAssignments> busAssignments;
  GetBusAssignmentForDriverData.fromJson(dynamic json):
  
  busAssignments = (json['busAssignments'] as List<dynamic>)
        .map((e) => GetBusAssignmentForDriverBusAssignments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBusAssignmentForDriverData otherTyped = other as GetBusAssignmentForDriverData;
    return busAssignments == otherTyped.busAssignments;
    
  }
  @override
  int get hashCode => busAssignments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['busAssignments'] = busAssignments.map((e) => e.toJson()).toList();
    return json;
  }

  GetBusAssignmentForDriverData({
    required this.busAssignments,
  });
}

