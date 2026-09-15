import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get _english => locale.languageCode == 'en';
  bool get _spanish => locale.languageCode == 'es';

  String get settings => _english
      ? 'Settings'
      : _spanish
          ? 'Configuracion'
          : 'Configurações';
  String get notifications => _english
      ? 'Notifications'
      : _spanish
          ? 'Notificaciones'
          : 'Notificações';
  String get theme => _english ? 'Theme' : _spanish ? 'Tema' : 'Tema';
  String get viewControl => _english
      ? 'View control'
      : _spanish
          ? 'Control de visualizaciones'
          : 'Controle de visualizações';
  String get language => _english ? 'Language' : _spanish ? 'Idioma' : 'Idioma';
  String get appLanguage => _english
      ? 'App language'
      : _spanish
          ? 'Idioma de la aplicacion'
          : 'Idioma do aplicativo';
  String get changePassword => _english
      ? 'Change password'
      : _spanish
          ? 'Cambiar contrasena'
          : 'Alterar senha';
  String get help => _english
      ? 'Help and support'
      : _spanish
          ? 'Ayuda y soporte'
          : 'Ajuda e suporte';
  String get about => _english
      ? 'About us'
      : _spanish
          ? 'Sobre nosotros'
          : 'Sobre nós';
  String get logout => _english
      ? 'Log out'
      : _spanish
          ? 'Cerrar sesion'
          : 'Sair da conta';
  String get deleteAccount => _english
      ? 'Delete account'
      : _spanish
          ? 'Eliminar cuenta'
          : 'Deletar conta';
      String get portugueseBrazil => 'Português (Brasil)';
  String get english => 'English';
    String get spanish => 'Español';

  String get welcome => _english ? 'Welcome!' : _spanish ? 'Bienvenido!' : 'Bem-vindo!';
  String get login => _english ? 'Log in' : _spanish ? 'Iniciar sesion' : 'Fazer Login';
  String get createAccount => _english ? 'Create account' : _spanish ? 'Crear cuenta' : 'Criar conta';
    String get continueLogin => _english
      ? 'Log in or create an account to continue'
      : _spanish
          ? 'Inicia sesion o crea tu cuenta para continuar'
          : 'Faça login ou crie sua conta para continuar';
  String get name => _english ? 'Name' : _spanish ? 'Nombre' : 'Nome';
  String get username => _english ? 'Username' : _spanish ? 'Nombre de usuario' : 'Username';
    String get email => _english ? 'Email' : _spanish ? 'Correo electrónico' : 'E-mail';
    String get password => _english ? 'Password' : _spanish ? 'Contraseña' : 'Senha';
    String get currentPassword => _english ? 'Current password' : _spanish ? 'Contraseña actual' : 'Senha atual';
    String get newPassword => _english ? 'New password' : _spanish ? 'Nueva contraseña' : 'Nova senha';
    String get confirmPassword => _english ? 'Confirm password' : _spanish ? 'Confirmar contraseña' : 'Confirmar senha';
    String get forgotPassword => _english ? 'Forgot your password?' : _spanish ? '¿Olvidaste tu contraseña?' : 'Esqueceu a senha?';
    String get noAccount => _english ? 'Do not have an account? ' : _spanish ? '¿No tienes una cuenta? ' : 'Não tem uma conta? ';
    String get signUp => _english ? 'Sign up' : _spanish ? 'Regístrate' : 'Cadastre-se';
  String get enter => _english ? 'Log in' : _spanish ? 'Entrar' : 'Entrar';
    String get fillLogin => _english ? 'Fill in your email/username and password.' : _spanish ? 'Completa tu correo/usuario y contraseña.' : 'Preencha o e-mail/username e a senha.';
    String get typeEmailOrUsername => _english ? 'Enter your email or username' : _spanish ? 'Escribe tu correo o usuario' : 'Digite seu e-mail ou usuário';
  String get typePassword => _english ? 'Enter your password' : _spanish ? 'Escribe tu contrasena' : 'Digite sua senha';
  String get typeName => _english ? 'Enter your name' : _spanish ? 'Escribe tu nombre' : 'Digite seu nome';
    String get typeUsername => _english ? 'Enter your username' : _spanish ? 'Escribe tu nombre de usuario' : 'Digite seu username';
  String get typeEmail => _english ? 'Enter your email' : _spanish ? 'Escribe tu correo' : 'Digite seu e-mail';
    String get typeBirthdate => _english ? 'Enter your birth date' : _spanish ? 'Escribe tu fecha de nacimiento' : 'Digite sua data de nascimento';
    String get register => _english ? 'Register' : _spanish ? 'Registrarse' : 'Cadastrar';
    String get alreadyAccount => _english ? 'I already have an account' : _spanish ? 'Ya tengo una cuenta' : 'Já tenho uma conta';
    String get passwordsDoNotMatch => _english ? 'Passwords do not match.' : _spanish ? 'Las contraseñas no coinciden.' : 'As senhas não coincidem.';
    String get passwordChanged => _english ? 'Password changed successfully.' : _spanish ? 'Contraseña cambiada correctamente.' : 'Senha alterada com sucesso.';
    String get sendCode => _english ? 'Send code' : _spanish ? 'Enviar código' : 'Enviar código';
    String get validateToken => _english ? 'Validate token' : _spanish ? 'Validar token' : 'Validar token';
    String get typeCode => _english ? '6-digit code' : _spanish ? 'Código de 6 dígitos' : 'Código de 6 números';
    String get backToLogin => _english ? 'Back to login' : _spanish ? 'Volver al inicio de sesión' : 'Voltar para o login';
    String get forgotPasswordDescription => _english ? 'Enter your email to receive the recovery link' : _spanish ? 'Escribe tu correo para recibir el enlace de recuperación' : 'Digite seu e-mail para receber o link de recuperação';
    String get codeSentDescription => _english ? 'Enter the 6-digit code sent to your email' : _spanish ? 'Escribe el código de 6 dígitos enviado a tu correo' : 'Digite o código de 6 números enviado para seu e-mail';
  String get customizeProfile => _english ? 'Customize profile' : _spanish ? 'Personalizar perfil' : 'Personalizar perfil';
    String get addPhoto => _english ? 'Add photo' : _spanish ? 'Agregar foto' : 'Adicionar foto';
  String get openingGallery => _english ? 'Opening gallery...' : _spanish ? 'Abriendo galeria...' : 'Abrindo galeria...';
  String get typeBio => _english ? 'Enter your bio' : _spanish ? 'Escribe tu biografia' : 'Digite sua biografia';
    String get later => _english ? 'Later' : _spanish ? 'Más tarde' : 'Deixar para mais tarde';
  String get customize => _english ? 'Customize' : _spanish ? 'Personalizar' : 'Personalizar';
  String get feed => _english ? 'Feed' : _spanish ? 'Feed' : 'Feed';
  String get profile => _english ? 'Profile' : _spanish ? 'Perfil' : 'Perfil';
    String get memories => _english ? 'Memories' : _spanish ? 'Memorias' : 'Memórias';
    String get biography => _english ? 'Bio' : _spanish ? 'Biografía' : 'Biografia';
  String get searchUser => _english ? 'user' : _spanish ? 'usuario' : 'usuario';
    String get saveMemories => _english ? 'Save memories in one click' : _spanish ? 'Guarda recuerdos con un clic' : 'Guarde memorias em um clique';
    String get privacyPreserved => _english ? 'Your privacy is preserved here' : _spanish ? 'Tu privacidad está protegida aquí' : 'Aqui sua privacidade é preservada';
    String get enjoyFriendsPhotos => _english ? 'Enjoy your friends photos' : _spanish ? 'Disfruta las fotos de tus amigos' : 'Curta as fotos dos seus amigos';
    String get fillAllFields => _english ? 'Fill in all fields' : _spanish ? 'Completa todos los campos' : 'Preencha todos os campos';
    String get invalidEmail => _english ? 'Enter a valid email' : _spanish ? 'Escreve um correo válido' : 'Digite um e-mail válido';
    String get selectBirthdate => _english ? 'Select your birth date' : _spanish ? 'Selecciona tu fecha de nacimiento' : 'Selecione sua data de nascimento';
    String get accountCreated => _english ? 'Account created successfully' : _spanish ? 'Cuenta creada correctamente' : 'Usuário cadastrado com sucesso';
    String get birthdate => _english ? 'Birth date' : _spanish ? 'Nacimiento' : 'Nascimento';
    String get checkEmail => _english ? 'Check your email and spam folder.' : _spanish ? 'Revisa tu correo y la carpeta de spam.' : 'Confira seu e-mail e a pasta Spam.';
    String get typeReceivedCode => _english ? 'Enter the 6-digit code received by email.' : _spanish ? 'Escribe el código de 6 dígitos recibido por correo.' : 'Digite o código de 6 números recebido por e-mail.';
    String get imageSelectionError => _english ? 'Unable to select the image.' : _spanish ? 'No se pudo seleccionar la imagen.' : 'Não foi possível selecionar a imagem.';
    String get dump => 'Dump';
    String get post => _english ? 'Post' : _spanish ? 'Publicar' : 'Postar';
    String get helpAndSupport => _english ? 'Help and support' : _spanish ? 'Ayuda y soporte' : 'Ajuda e suporte';
    String get logoutShort => _english ? 'Log out' : _spanish ? 'Salir' : 'Sair';
    String get search => _english ? 'Search' : _spanish ? 'Buscar' : 'Pesquisar';
    String get editProfile => _english ? 'Edit profile' : _spanish ? 'Editar perfil' : 'Editar perfil';
    String get save => _english ? 'Save changes' : _spanish ? 'Guardar cambios' : 'Salvar alterações';
    String get friends => _english ? 'Friends' : _spanish ? 'Amigos' : 'Amigos';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
