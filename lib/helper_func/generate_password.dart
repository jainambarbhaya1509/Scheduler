import 'dart:math';

String generateRandomPassword() {
  const chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#%^*!?";
  final rand = Random.secure();

  return List.generate(10, (i) => chars[rand.nextInt(chars.length)]).join();
}
