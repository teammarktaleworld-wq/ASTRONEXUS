class AstrologySignupModel {
  // ------------------ Basic user info ------------------
  String name;
  String email;
  String phone;
  String password;
  String confirmPassword;

  // ------------------ Birth info ------------------
  String dateOfBirth; // format: "YYYY-MM-DD"
  int hour; // 1-12
  int minute; // 0-59
  bool isAM; // true = AM, false = PM
  String place; // city, country
  double timezone; // e.g., 5.5

  // ⭐ Temporary chart ID (from birth chart generation)
  String tempChartId;

  // ------------------ Constructor ------------------
  AstrologySignupModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.dateOfBirth = '',
    this.hour = 12,
    this.minute = 0,
    this.isAM = true,
    this.place = '',
    this.timezone = 5.5,
    this.tempChartId = '',
  });

  // ------------------ Convert to API-ready JSON ------------------
  Map<String, dynamic> toJson() {
    final hour24 = isAM ? hour % 12 : (hour % 12) + 12;
    final timeString =
        '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    var sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedPhone.length == 11 && sanitizedPhone.startsWith('0')) {
      sanitizedPhone = sanitizedPhone.substring(1);
    } else if (sanitizedPhone.length == 12 && sanitizedPhone.startsWith('91')) {
      sanitizedPhone = sanitizedPhone.substring(2);
    }

    return {
      "name": name.trim(),
      "email": email.trim(),
      "phone": sanitizedPhone,
      "password": password,
      "confirmPassword": confirmPassword,
      "dateOfBirth": dateOfBirth,
      "timeOfBirth": timeString,
      "placeOfBirth": place.trim(),
      "tempChartId": tempChartId,
    };
  }
}
