library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'list_routes.dart';

part 'update_student_allergies.dart';

part 'get_bus_assignment_for_driver.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  ListRoutesVariablesBuilder listRoutes () {
    return ListRoutesVariablesBuilder(dataConnect, );
  }
  
  
  UpdateStudentAllergiesVariablesBuilder updateStudentAllergies ({required String studentId, }) {
    return UpdateStudentAllergiesVariablesBuilder(dataConnect, studentId: studentId,);
  }
  
  
  GetBusAssignmentForDriverVariablesBuilder getBusAssignmentForDriver () {
    return GetBusAssignmentForDriverVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-west3',
    'example',
    'appphoto',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
