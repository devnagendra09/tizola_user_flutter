class PhoneValidator {
  static String normalize(String input) {
    var phone = input.replaceAll(RegExp(r'[\+\-\s\(\)]'), '');
    if (phone.length > 10) {
      phone = phone.substring(phone.length - 10);
    }
    return phone;
  }

  static bool isValidIndianMobile(String input) {
    final phone = normalize(input);
    return RegExp(r'^[6789]\d{9}$').hasMatch(phone);
  }
}
