import 'dart:core';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

class WorkoutHeader {
  final DateTime startTime;

  WorkoutHeader(this.startTime);
}

class WorkoutRecord {
  final DateTime timestamp;
  final int heartRate;
  final int cadence;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'cadence': cadence,
    };
  }

  WorkoutRecord(this.timestamp, this.heartRate, this.cadence);

  WorkoutRecord.fromJson(Map<String, dynamic> value)
      : timestamp = DateTime.parse(value['timestamp']),
        heartRate = value['heartRate'],
        cadence = value['cadence'];
}

class WorkoutSummary {
  final Duration totalTime;

  WorkoutSummary(this.totalTime);
}

class _InitializeMessage {
  // If messageType == startup, these fields are present
  final String fileName;
  // The background worker calls us back on this port when startup is complete.
  final SendPort startupPort;

  final SendPort shutdownPort;

  _InitializeMessage(this.fileName, this.startupPort, this.shutdownPort);
}

enum _MessageType {start, writeRecord, finish}

class _WorkoutMessage {
  final _MessageType messageType;

  // If messageType == start, this field is present
  final WorkoutHeader header;

  // If messageType == writeRecord, this field is present
  final WorkoutRecord record;

  // If messageType == finish, this field is presentj
  final WorkoutSummary summary;

  _WorkoutMessage(this.messageType, {this.header, this.record, this.summary});
}

class WorkoutRecorder {
  final String workoutFileName;

  WorkoutRecorder(this.workoutFileName);

  ReceivePort _startupPort;
  ReceivePort _shutdownPort;
  SendPort _sendPort;

  Future<void> initialize() async {
    _startupPort = ReceivePort();
    _shutdownPort = ReceivePort();
    await Isolate.spawn(backgroundWorker,
        _InitializeMessage(workoutFileName, _startupPort.sendPort, _shutdownPort.sendPort));
    _sendPort =  await _startupPort.first;
  }

  void start(WorkoutHeader header) {
    _sendPort.send(_WorkoutMessage(_MessageType.start, header: header));
  } 

  void record(WorkoutRecord record) {
    _sendPort.send(_WorkoutMessage(_MessageType.writeRecord, record: record));
  }

  Future<void> finish(WorkoutSummary summary) async {
    _sendPort.send(_WorkoutMessage(_MessageType.finish, summary: summary));
    String msg = await _shutdownPort.first;
    print(msg);
  }

  static String _getStartXml(WorkoutHeader header) {
    String dateString = header.startTime.toIso8601String();
    return """
<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase 
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 https://www8.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Activities>
    <Activity Sport="Biking">
      <Id>${dateString}</Id> 
      <Lap StartTime="${dateString}">
        <TotalTimeSeconds>10000</TotalTimeSeconds>
        <DistanceMeters>0.0</DistanceMeters>
        <Calories>0</Calories>
        <Intensity>Active</Intensity>
        <TriggerMethod>Manual</TriggerMethod>
        <Track>""";
  }

  static String _getTrackXml(WorkoutRecord record) {
    String heartRateValue = record.heartRate != null ? "<HeartRateBpm><Value>${record.heartRate}</Value></HeartRateBpm>" : "";
    String cadenceValue = record.cadence != null ? "<Cadence>${record.cadence}</Cadence>" : "";
    return """
          <Trackpoint>
            <Time>${record.timestamp.toIso8601String()}</Time>$heartRateValue$cadenceValue
          </Trackpoint>""";
  }

  static String _getEndXml(WorkoutSummary summary) {
    return """
        </Track>
      </Lap>
    </Activity>
  </Activities>    
</TrainingCenterDatabase>""";
  }
  static void backgroundWorker(_InitializeMessage initialMessage) async {
    ReceivePort receivePort = ReceivePort();
    initialMessage.startupPort.send(receivePort.sendPort);

    var file = File(initialMessage.fileName);
    var sink = file.openWrite();

    // Wait for messages!
    await for (_WorkoutMessage msg in receivePort) {
      switch (msg.messageType) {
        case _MessageType.start:
          sink.write(_getStartXml(msg.header));
          break;
        case _MessageType.finish:
          receivePort.close();
          sink.write(_getEndXml(msg.summary));
          break;
        case _MessageType.writeRecord:
          sink.write(_getTrackXml(msg.record));
          break;
      }
    }
    await sink.close();
    initialMessage.shutdownPort.send('worker finished');
  }
}
