import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/phone_numbers.dart';

void main() {
  final ethiopia = countryCallingCodeByIso('ET');
  final unitedStates = countryCallingCodeByIso('US');

  group('normalizePhoneNumber', () {
    test('accepts Ethiopian local numbers and expands them to E.164', () {
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '0911223344'),
        '+251911223344',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '0711223344'),
        '+251711223344',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '911223344'),
        '+251911223344',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '711223344'),
        '+251711223344',
      );
    });

    test('accepts already-normalized Ethiopian numbers', () {
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '+251911223344'),
        '+251911223344',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '251911223344'),
        '+251911223344',
      );
    });

    test('rejects malformed Ethiopian numbers', () {
      expect(normalizePhoneNumber(country: ethiopia, rawInput: '12345'), '');
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '0811223344'),
        '',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '811223344'),
        '',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '+25191122334'),
        '',
      );
      expect(
        normalizePhoneNumber(country: ethiopia, rawInput: '+251811223344'),
        '',
      );
    });

    test('normalizes non-Ethiopian numbers with the selected dial code', () {
      expect(
        normalizePhoneNumber(country: unitedStates, rawInput: '4155552671'),
        '+14155552671',
      );
      expect(
        normalizePhoneNumber(country: unitedStates, rawInput: '(415) 555-2671'),
        '+14155552671',
      );
    });

    test(
      'keeps a matching explicit country code for non-Ethiopian numbers',
      () {
        expect(
          normalizePhoneNumber(country: unitedStates, rawInput: '+14155552671'),
          '+14155552671',
        );
      },
    );

    test('rejects explicit numbers with the wrong dial code', () {
      expect(
        normalizePhoneNumber(country: unitedStates, rawInput: '+251911223344'),
        '',
      );
    });
  });
}
