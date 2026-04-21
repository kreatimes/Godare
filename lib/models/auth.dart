// Petición de registro — debe coincidir con RegisterRequest del back
class RegisterRequest {
  final String nick;
  final String name;
  final String? surnames;
  final String email;
  final String password;

  const RegisterRequest({
    required this.nick,
    required this.name,
    this.surnames,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nick': nick,
    'name': name,
    'surnames': surnames,
    'email': email,
    'password': password,
  };
}

// Petición de login — permite email o nick
class LoginRequest {
  final String emailOrNick;
  final String password;

  const LoginRequest({
    required this.emailOrNick,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'emailOrNick': emailOrNick,
    'password': password,
  };
}

// Respuesta del login con el JWT y datos básicos del usuario
class JwtResponse {
  final String token;
  final String type;
  final String id;
  final String nick;
  final String email;
  final int points;
  final int coinsApp;
  final int range;

  const JwtResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.nick,
    required this.email,
    required this.points,
    required this.coinsApp,
    required this.range,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      token: json['token'],
      type: json['type'],
      id: json['id'],
      nick: json['nick'],
      email: json['email'],
      points: json['points'] ?? 0,
      coinsApp: json['coinsApp'] ?? 0,
      range: json['range'] ?? 1,
    );
  }
}

// Petición de recuperación de contraseña
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Petición de reset de contraseña con token
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'newPassword': newPassword,
  };
}

// Petición de cambio de contraseña con sesión activa
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}