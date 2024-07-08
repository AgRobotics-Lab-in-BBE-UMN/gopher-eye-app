String? emailvalidator(String? email) {
  RegExp emailregex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final isemailvalid = emailregex.hasMatch(email ?? '');
  if (!isemailvalid) {
    return 'Please Enter valid Email-ID';
  }
  return null;
}

//*password validator

String? passwordvalidator(String? password) {
  RegExp passwordregex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$^+=!*()@%&]).{8,}$');
  final ispassvalid = passwordregex.hasMatch(password ?? '');
  if (!ispassvalid) {
    return 'Please Enter a valid Password';
  }
  return null;
}