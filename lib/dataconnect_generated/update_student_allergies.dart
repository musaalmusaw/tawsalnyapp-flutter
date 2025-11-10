part of 'generated.dart';

class UpdateStudentAllergiesVariablesBuilder {
  String studentId;
  Optional<String> _allergies = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpdateStudentAllergiesVariablesBuilder allergies(String? t) {
   _allergies.value = t;
   return this;
  }

  UpdateStudentAllergiesVariablesBuilder(this._dataConnect, {required  this.studentId,});
  Deserializer<UpdateStudentAllergiesData> dataDeserializer = (dynamic json)  => UpdateStudentAllergiesData.fromJson(jsonDecode(json));
  Serializer<UpdateStudentAllergiesVariables> varsSerializer = (UpdateStudentAllergiesVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateStudentAllergiesData, UpdateStudentAllergiesVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateStudentAllergiesData, UpdateStudentAllergiesVariables> ref() {
    UpdateStudentAllergiesVariables vars= UpdateStudentAllergiesVariables(studentId: studentId,allergies: _allergies,);
    return _dataConnect.mutation("UpdateStudentAllergies", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateStudentAllergiesStudentUpdate {
  final String id;
  UpdateStudentAllergiesStudentUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateStudentAllergiesStudentUpdate otherTyped = other as UpdateStudentAllergiesStudentUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateStudentAllergiesStudentUpdate({
    required this.id,
  });
}

@immutable
class UpdateStudentAllergiesData {
  final UpdateStudentAllergiesStudentUpdate? student_update;
  UpdateStudentAllergiesData.fromJson(dynamic json):
  
  student_update = json['student_update'] == null ? null : UpdateStudentAllergiesStudentUpdate.fromJson(json['student_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateStudentAllergiesData otherTyped = other as UpdateStudentAllergiesData;
    return student_update == otherTyped.student_update;
    
  }
  @override
  int get hashCode => student_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (student_update != null) {
      json['student_update'] = student_update!.toJson();
    }
    return json;
  }

  UpdateStudentAllergiesData({
    this.student_update,
  });
}

@immutable
class UpdateStudentAllergiesVariables {
  final String studentId;
  late final Optional<String>allergies;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateStudentAllergiesVariables.fromJson(Map<String, dynamic> json):
  
  studentId = nativeFromJson<String>(json['studentId']) {
  
  
  
    allergies = Optional.optional(nativeFromJson, nativeToJson);
    allergies.value = json['allergies'] == null ? null : nativeFromJson<String>(json['allergies']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateStudentAllergiesVariables otherTyped = other as UpdateStudentAllergiesVariables;
    return studentId == otherTyped.studentId && 
    allergies == otherTyped.allergies;
    
  }
  @override
  int get hashCode => Object.hashAll([studentId.hashCode, allergies.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    if(allergies.state == OptionalState.set) {
      json['allergies'] = allergies.toJson();
    }
    return json;
  }

  UpdateStudentAllergiesVariables({
    required this.studentId,
    required this.allergies,
  });
}

