import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../models/voter.dart';
import '../services/firebase_service.dart';

class VoterImportService {
  static final VoterImportService _instance = VoterImportService._internal();
  factory VoterImportService() => _instance;
  VoterImportService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  /// Import voters from a file (CSV or JSON)
  Future<ImportResult> importVotersFromFile({String? stationId}) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return ImportResult(success: false, message: 'No file selected');
      }

      final file = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();

      List<Voter> voters = [];

      switch (extension) {
        case 'csv':
          voters = await _parseCsvFile(file, stationId: stationId);
          break;
        case 'json':
          voters = await _parseJsonFile(file, stationId: stationId);
          break;
        default:
          return ImportResult(
            success: false,
            message: 'Unsupported file format. Please use CSV or JSON.',
          );
      }

      if (voters.isEmpty) {
        return ImportResult(
          success: false,
          message: 'No valid voter data found in file',
        );
      }

      // Import to Firebase
      await _firebaseService.addVotersBatch(voters);

      return ImportResult(
        success: true,
        message: 'Successfully imported ${voters.length} voters',
        importedCount: voters.length,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: ${e.toString()}',
      );
    }
  }

  /// Parse CSV file to voters list
  Future<List<Voter>> _parseCsvFile(File file, {String? stationId}) async {
    final input = await file.readAsString();
    final rows = const CsvToListConverter().convert(input);

    if (rows.isEmpty) return [];

    // Skip header row if exists
    final dataRows = rows.length > 1 && _isHeaderRow(rows.first)
        ? rows.skip(1)
        : rows;

    List<Voter> voters = [];

    for (var row in dataRows) {
      try {
        // Expected CSV format: CNIC, Name, Father_Name, Address, [Is_Eligible]
        // Station_ID column is now optional - will use provided stationId if available
        if (row.length < 4) continue;

        final cnic = row[0].toString().trim();
        final name = row[1].toString().trim();
        final fatherName = row[2].toString().trim();
        final address = row[3].toString().trim();

        // Use provided stationId, or read from CSV if column exists
        String finalStationId;
        if (stationId != null && stationId.isNotEmpty) {
          finalStationId = stationId;
        } else if (row.length > 4) {
          finalStationId = row[4].toString().trim();
        } else {
          continue; // Skip if no station ID available
        }

        final isEligible = row.length > 5
            ? _parseBool(row[5].toString())
            : (row.length > 4 && stationId != null
                  ? _parseBool(row[4].toString())
                  : true);

        if (cnic.isNotEmpty && name.isNotEmpty && finalStationId.isNotEmpty) {
          voters.add(
            Voter(
              id: cnic,
              name: name,
              fatherName: fatherName,
              cnic: cnic,
              address: address,
              stationId: finalStationId,
              isEligible: isEligible,
            ),
          );
        }
      } catch (e) {
        // Skip invalid rows
        continue;
      }
    }

    return voters;
  }

  /// Parse JSON file to voters list
  Future<List<Voter>> _parseJsonFile(File file, {String? stationId}) async {
    final content = await file.readAsString();
    final data = json.decode(content);

    List<Voter> voters = [];

    if (data is List) {
      for (var item in data) {
        try {
          final voter = Voter.fromJson(item);
          // Override station ID if provided
          if (stationId != null && stationId.isNotEmpty) {
            voters.add(voter.copyWith(stationId: stationId));
          } else {
            voters.add(voter);
          }
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    } else if (data is Map && data.containsKey('voters')) {
      final votersList = data['voters'];
      if (votersList is List) {
        for (var item in votersList) {
          try {
            final voter = Voter.fromJson(item);
            // Override station ID if provided
            if (stationId != null && stationId.isNotEmpty) {
              voters.add(voter.copyWith(stationId: stationId));
            } else {
              voters.add(voter);
            }
          } catch (e) {
            // Skip invalid entries
            continue;
          }
        }
      }
    }

    return voters;
  }

  /// Check if first row is likely a header
  bool _isHeaderRow(List row) {
    if (row.isEmpty) return false;

    final firstCell = row.first.toString().toLowerCase();
    return firstCell.contains('cnic') ||
        firstCell.contains('name') ||
        firstCell.contains('id');
  }

  /// Parse boolean from string
  bool _parseBool(String value) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
  }

  /// Generate sample CSV template
  String generateSampleCsv() {
    return '''CNIC,Name,Father_Name,Address,Station_ID,Is_Eligible
3520212345678,Ahmed Raza,Raza Ali,"House 10, Street 5, Lahore",station_001,true
3520212345679,Sara Khan,Khan Ali,"House 15, Street 8, Lahore",station_001,true
3520212345680,Usman Ahmed,Ahmed Ali,"House 20, Street 12, Karachi",station_002,false''';
  }

  /// Generate sample JSON template
  String generateSampleJson() {
    return '''{
  "voters": [
    {
      "doc_id": "3520212345678",
      "name": "Ahmed Raza",
      "father_name": "Raza Ali", 
      "cnic": "3520212345678",
      "address": "House 10, Street 5, Lahore",
      "station_id": "station_001",
      "is_eligible": true,
      "has_voted": false,
      "voted_at": null
    },
    {
      "doc_id": "3520212345679",
      "name": "Sara Khan", 
      "father_name": "Khan Ali",
      "cnic": "3520212345679", 
      "address": "House 15, Street 8, Lahore",
      "station_id": "station_001",
      "is_eligible": true,
      "has_voted": false,
      "voted_at": null
    }
  ]
}''';
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int importedCount;

  ImportResult({
    required this.success,
    required this.message,
    this.importedCount = 0,
  });
}
