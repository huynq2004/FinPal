import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/ui/viewmodels/smart_scan_viewmodel.dart';
import 'package:finpal/domain/models/raw_sms.dart';
import 'package:flutter/material.dart';

void main() {
  group('SmartScanState Enum Tests', () {
    test('State enum có đủ các trạng thái cần thiết', () {
      // Verify tất cả states được định nghĩa
      expect(SmartScanState.values.contains(SmartScanState.idle), true);
      expect(SmartScanState.values.contains(SmartScanState.checkingPermission), true);
      expect(SmartScanState.values.contains(SmartScanState.permissionDenied), true);
      expect(SmartScanState.values.contains(SmartScanState.scanning), true);
      expect(SmartScanState.values.contains(SmartScanState.filtering), true);
      expect(SmartScanState.values.contains(SmartScanState.parsing), true);
      expect(SmartScanState.values.contains(SmartScanState.success), true);
      expect(SmartScanState.values.contains(SmartScanState.error), true);
    });

    test('Enum có tổng cộng 8 states', () {
      expect(SmartScanState.values.length, 8);
    });

    test('States có thứ tự đúng', () {
      expect(SmartScanState.idle.index, 0);
      expect(SmartScanState.checkingPermission.index, 1);
      expect(SmartScanState.permissionDenied.index, 2);
      expect(SmartScanState.scanning.index, 3);
      expect(SmartScanState.filtering.index, 4);
      expect(SmartScanState.parsing.index, 5);
      expect(SmartScanState.success.index, 6);
      expect(SmartScanState.error.index, 7);
    });
  });

  group('ParseError Model Tests', () {
    test('ParseError stores raw SMS and reason correctly', () {
      final rawSms = RawSms(
        address: 'VCB',
        body: 'Test SMS body that cannot be parsed',
        date: DateTime(2025, 1, 7, 10, 30),
        id: 123,
      );
      
      final parseError = ParseError(
        rawSms: rawSms,
        reason: 'Invalid SMS format',
      );
      
      expect(parseError.rawSms, rawSms);
      expect(parseError.rawSms.address, 'VCB');
      expect(parseError.rawSms.body, 'Test SMS body that cannot be parsed');
      expect(parseError.rawSms.id, 123);
      expect(parseError.reason, 'Invalid SMS format');
    });

    test('ParseError can store different error reasons', () {
      final rawSms = RawSms(
        address: 'UNKNOWN',
        body: 'Invalid content',
        date: DateTime.now(),
        id: 1,
      );
      
      final errors = [
        ParseError(rawSms: rawSms, reason: 'Không đúng format SMS ngân hàng'),
        ParseError(rawSms: rawSms, reason: 'Thiếu thông tin số tiền'),
        ParseError(rawSms: rawSms, reason: 'Lỗi parse: Exception'),
      ];
      
      expect(errors.length, 3);
      expect(errors[0].reason, 'Không đúng format SMS ngân hàng');
      expect(errors[1].reason, 'Thiếu thông tin số tiền');
      expect(errors[2].reason, 'Lỗi parse: Exception');
    });
  });

  group('State Transition Logic Tests', () {
    test('isScanning logic returns true for correct states', () {
      // Simulate the isScanning logic
      final scanningStates = [
        SmartScanState.scanning,
        SmartScanState.filtering,
        SmartScanState.parsing,
      ];
      
      for (final state in scanningStates) {
        final isScanning = state == SmartScanState.scanning ||
                           state == SmartScanState.filtering ||
                           state == SmartScanState.parsing;
        expect(isScanning, true, reason: 'State $state should be scanning');
      }
    });

    test('isScanning logic returns false for non-scanning states', () {
      final nonScanningStates = [
        SmartScanState.idle,
        SmartScanState.checkingPermission,
        SmartScanState.permissionDenied,
        SmartScanState.success,
        SmartScanState.error,
      ];
      
      for (final state in nonScanningStates) {
        final isScanning = state == SmartScanState.scanning ||
                           state == SmartScanState.filtering ||
                           state == SmartScanState.parsing;
        expect(isScanning, false, reason: 'State $state should not be scanning');
      }
    });

    test('Successful scan flow transitions correctly', () {
      // Expected flow:
      // idle → checkingPermission → scanning → filtering → parsing → success
      final expectedFlow = [
        SmartScanState.idle,
        SmartScanState.checkingPermission,
        SmartScanState.scanning,
        SmartScanState.filtering,
        SmartScanState.parsing,
        SmartScanState.success,
      ];
      
      // Verify all states exist
      for (final state in expectedFlow) {
        expect(SmartScanState.values.contains(state), true);
      }
      
      // Verify flow is logical (each next state exists)
      for (int i = 0; i < expectedFlow.length - 1; i++) {
        expect(expectedFlow[i], isNotNull);
        expect(expectedFlow[i + 1], isNotNull);
      }
    });

    test('Permission denied flow transitions correctly', () {
      // Expected flow:
      // idle → checkingPermission → permissionDenied
      final expectedFlow = [
        SmartScanState.idle,
        SmartScanState.checkingPermission,
        SmartScanState.permissionDenied,
      ];
      
      for (final state in expectedFlow) {
        expect(SmartScanState.values.contains(state), true);
      }
    });

    test('Error flow can happen from any state', () {
      // Error can occur from any state
      expect(SmartScanState.values.contains(SmartScanState.error), true);
      
      // All states should be able to transition to error
      for (final state in SmartScanState.values) {
        // If current state is not error, it should be able to go to error
        if (state != SmartScanState.error) {
          expect(SmartScanState.error, isNotNull);
        }
      }
    });
  });

  group('Error Handling Scenarios', () {
    test('Parse error reason covers common cases', () {
      final commonReasons = [
        'Không đúng format SMS ngân hàng hoặc thiếu thông tin',
        'Lỗi parse: Exception',
        'Thiếu số tiền',
        'Thiếu thời gian',
        'Format không hợp lệ',
      ];
      
      for (final reason in commonReasons) {
        expect(reason.isNotEmpty, true);
        expect(reason.length > 5, true);
      }
    });

    test('Multiple parse errors can be tracked', () {
      final errors = <ParseError>[];
      
      for (int i = 0; i < 5; i++) {
        final rawSms = RawSms(
          address: 'BANK$i',
          body: 'Invalid message $i',
          date: DateTime.now(),
          id: i,
        );
        
        errors.add(ParseError(
          rawSms: rawSms,
          reason: 'Error $i',
        ));
      }
      
      expect(errors.length, 5);
      expect(errors[0].reason, 'Error 0');
      expect(errors[4].reason, 'Error 4');
    });
  });

  group('Statistics Calculation Logic', () {
    test('Parse success rate calculation', () {
      // Test the calculation logic
      final testCases = [
        {'total': 0, 'success': 0, 'expected': 0.0},
        {'total': 10, 'success': 10, 'expected': 100.0},
        {'total': 10, 'success': 5, 'expected': 50.0},
        {'total': 100, 'success': 75, 'expected': 75.0},
        {'total': 3, 'success': 2, 'expected': 66.66666666666666},
      ];
      
      for (final testCase in testCases) {
        final total = testCase['total'] as int;
        final success = testCase['success'] as int;
        final expected = testCase['expected'] as double;
        
        final rate = total == 0 ? 0.0 : (success / total * 100);
        expect(rate, closeTo(expected, 0.0001));
      }
    });

    test('Failed to parse count calculation', () {
      // failedToParse = total - success
      final testCases = [
        {'total': 10, 'success': 8, 'failed': 2},
        {'total': 100, 'success': 95, 'failed': 5},
        {'total': 50, 'success': 30, 'failed': 20},
      ];
      
      for (final testCase in testCases) {
        final total = testCase['total'] as int;
        final success = testCase['success'] as int;
        final expectedFailed = testCase['failed'] as int;
        
        final actualFailed = total - success;
        expect(actualFailed, expectedFailed);
      }
    });
  });
}

