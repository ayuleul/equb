class CountryCallingCode {
  const CountryCallingCode({
    required this.isoCode,
    required this.name,
    required this.dialCode,
    required this.flagEmoji,
    this.nationalExample = 'Phone number',
    this.supportText = '',
    this.minNationalLength = 4,
    this.maxNationalLength = 14,
    this.stripLeadingZero = true,
    this.allowedNationalPrefixes = const <String>[],
  });

  final String isoCode;
  final String name;
  final String dialCode;
  final String flagEmoji;
  final String nationalExample;
  final String supportText;
  final int minNationalLength;
  final int maxNationalLength;
  final bool stripLeadingZero;
  final List<String> allowedNationalPrefixes;

  String get dialDigits => dialCode.replaceAll('+', '');

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalized) ||
        isoCode.toLowerCase().contains(normalized) ||
        dialCode.contains(normalized);
  }
}

class PhoneNumberValue {
  const PhoneNumberValue({required this.country, required this.rawInput});

  final CountryCallingCode country;
  final String rawInput;

  String? get normalizedPhone =>
      normalizePhoneNumber(country: country, rawInput: rawInput);

  bool get isEmpty => rawInput.trim().isEmpty;

  PhoneNumberValue copyWith({CountryCallingCode? country, String? rawInput}) {
    return PhoneNumberValue(
      country: country ?? this.country,
      rawInput: rawInput ?? this.rawInput,
    );
  }
}

const List<CountryCallingCode> kCountryCallingCodes = [
  CountryCallingCode(
    isoCode: 'ET',
    name: 'Ethiopia',
    dialCode: '+251',
    flagEmoji: '🇪🇹',
    nationalExample: '91 122 3344',
    minNationalLength: 9,
    maxNationalLength: 9,
    allowedNationalPrefixes: ['9', '7'],
  ),
  CountryCallingCode(
    isoCode: 'AU',
    name: 'Australia',
    dialCode: '+61',
    flagEmoji: '🇦🇺',
  ),
  CountryCallingCode(
    isoCode: 'BH',
    name: 'Bahrain',
    dialCode: '+973',
    flagEmoji: '🇧🇭',
  ),
  CountryCallingCode(
    isoCode: 'BI',
    name: 'Burundi',
    dialCode: '+257',
    flagEmoji: '🇧🇮',
  ),
  CountryCallingCode(
    isoCode: 'CA',
    name: 'Canada',
    dialCode: '+1',
    flagEmoji: '🇨🇦',
  ),
  CountryCallingCode(
    isoCode: 'CN',
    name: 'China',
    dialCode: '+86',
    flagEmoji: '🇨🇳',
  ),
  CountryCallingCode(
    isoCode: 'DJ',
    name: 'Djibouti',
    dialCode: '+253',
    flagEmoji: '🇩🇯',
  ),
  CountryCallingCode(
    isoCode: 'EG',
    name: 'Egypt',
    dialCode: '+20',
    flagEmoji: '🇪🇬',
  ),
  CountryCallingCode(
    isoCode: 'ER',
    name: 'Eritrea',
    dialCode: '+291',
    flagEmoji: '🇪🇷',
  ),
  CountryCallingCode(
    isoCode: 'FR',
    name: 'France',
    dialCode: '+33',
    flagEmoji: '🇫🇷',
  ),
  CountryCallingCode(
    isoCode: 'DE',
    name: 'Germany',
    dialCode: '+49',
    flagEmoji: '🇩🇪',
  ),
  CountryCallingCode(
    isoCode: 'GH',
    name: 'Ghana',
    dialCode: '+233',
    flagEmoji: '🇬🇭',
  ),
  CountryCallingCode(
    isoCode: 'IN',
    name: 'India',
    dialCode: '+91',
    flagEmoji: '🇮🇳',
  ),
  CountryCallingCode(
    isoCode: 'IT',
    name: 'Italy',
    dialCode: '+39',
    flagEmoji: '🇮🇹',
  ),
  CountryCallingCode(
    isoCode: 'KE',
    name: 'Kenya',
    dialCode: '+254',
    flagEmoji: '🇰🇪',
  ),
  CountryCallingCode(
    isoCode: 'KW',
    name: 'Kuwait',
    dialCode: '+965',
    flagEmoji: '🇰🇼',
  ),
  CountryCallingCode(
    isoCode: 'NL',
    name: 'Netherlands',
    dialCode: '+31',
    flagEmoji: '🇳🇱',
  ),
  CountryCallingCode(
    isoCode: 'NG',
    name: 'Nigeria',
    dialCode: '+234',
    flagEmoji: '🇳🇬',
  ),
  CountryCallingCode(
    isoCode: 'NO',
    name: 'Norway',
    dialCode: '+47',
    flagEmoji: '🇳🇴',
  ),
  CountryCallingCode(
    isoCode: 'OM',
    name: 'Oman',
    dialCode: '+968',
    flagEmoji: '🇴🇲',
  ),
  CountryCallingCode(
    isoCode: 'QA',
    name: 'Qatar',
    dialCode: '+974',
    flagEmoji: '🇶🇦',
  ),
  CountryCallingCode(
    isoCode: 'RW',
    name: 'Rwanda',
    dialCode: '+250',
    flagEmoji: '🇷🇼',
  ),
  CountryCallingCode(
    isoCode: 'SA',
    name: 'Saudi Arabia',
    dialCode: '+966',
    flagEmoji: '🇸🇦',
  ),
  CountryCallingCode(
    isoCode: 'SO',
    name: 'Somalia',
    dialCode: '+252',
    flagEmoji: '🇸🇴',
  ),
  CountryCallingCode(
    isoCode: 'ZA',
    name: 'South Africa',
    dialCode: '+27',
    flagEmoji: '🇿🇦',
  ),
  CountryCallingCode(
    isoCode: 'SS',
    name: 'South Sudan',
    dialCode: '+211',
    flagEmoji: '🇸🇸',
  ),
  CountryCallingCode(
    isoCode: 'SD',
    name: 'Sudan',
    dialCode: '+249',
    flagEmoji: '🇸🇩',
  ),
  CountryCallingCode(
    isoCode: 'SE',
    name: 'Sweden',
    dialCode: '+46',
    flagEmoji: '🇸🇪',
  ),
  CountryCallingCode(
    isoCode: 'TZ',
    name: 'Tanzania',
    dialCode: '+255',
    flagEmoji: '🇹🇿',
  ),
  CountryCallingCode(
    isoCode: 'TR',
    name: 'Turkey',
    dialCode: '+90',
    flagEmoji: '🇹🇷',
  ),
  CountryCallingCode(
    isoCode: 'AE',
    name: 'United Arab Emirates',
    dialCode: '+971',
    flagEmoji: '🇦🇪',
  ),
  CountryCallingCode(
    isoCode: 'GB',
    name: 'United Kingdom',
    dialCode: '+44',
    flagEmoji: '🇬🇧',
  ),
  CountryCallingCode(
    isoCode: 'US',
    name: 'United States',
    dialCode: '+1',
    flagEmoji: '🇺🇸',
  ),
  CountryCallingCode(
    isoCode: 'UG',
    name: 'Uganda',
    dialCode: '+256',
    flagEmoji: '🇺🇬',
  ),
];

CountryCallingCode countryCallingCodeByIso(String isoCode) {
  return kCountryCallingCodes.firstWhere(
    (country) => country.isoCode == isoCode,
  );
}

PhoneNumberValue phoneNumberValueFromStoredPhone(String? phone) {
  final fallback = countryCallingCodeByIso('ET');
  final trimmed = phone?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return PhoneNumberValue(country: fallback, rawInput: '');
  }

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  final country = _matchCountryByDigits(digits) ?? fallback;
  final rawInput = digits.startsWith(country.dialDigits)
      ? digits.substring(country.dialDigits.length)
      : trimmed;

  return PhoneNumberValue(country: country, rawInput: rawInput);
}

String? normalizePhoneNumber({
  required CountryCallingCode country,
  required String rawInput,
}) {
  final trimmed = rawInput.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final compact = trimmed.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  if (compact.isEmpty) {
    return null;
  }

  final digits = compact.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return null;
  }

  if (compact.startsWith('+')) {
    if (!digits.startsWith(country.dialDigits)) {
      return '';
    }

    final nationalDigits = digits.substring(country.dialDigits.length);
    if (!_isValidNationalNumber(country, nationalDigits)) {
      return '';
    }

    return '+$digits';
  }

  if (digits.startsWith(country.dialDigits) &&
      _isValidNationalNumber(
        country,
        digits.substring(country.dialDigits.length),
      )) {
    return '+$digits';
  }

  final national = country.stripLeadingZero && digits.startsWith('0')
      ? digits.substring(1)
      : digits;
  if (!_isValidNationalNumber(country, national)) {
    return '';
  }

  return '${country.dialCode}$national';
}

CountryCallingCode? _matchCountryByDigits(String digits) {
  CountryCallingCode? bestMatch;
  for (final country in kCountryCallingCodes) {
    if (!digits.startsWith(country.dialDigits) ||
        digits.length <= country.dialDigits.length) {
      continue;
    }

    if (bestMatch == null ||
        country.dialDigits.length > bestMatch.dialDigits.length) {
      bestMatch = country;
    }
  }
  return bestMatch;
}

bool _isValidNationalNumber(CountryCallingCode country, String nationalDigits) {
  return nationalDigits.length >= country.minNationalLength &&
      nationalDigits.length <= country.maxNationalLength &&
      _hasValidNationalPrefix(country, nationalDigits);
}

bool _hasValidNationalPrefix(
  CountryCallingCode country,
  String nationalDigits,
) {
  if (country.allowedNationalPrefixes.isEmpty) {
    return true;
  }

  return country.allowedNationalPrefixes.any(
    (prefix) => nationalDigits.startsWith(prefix),
  );
}
