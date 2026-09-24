import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'backend_config.dart';

Future<void> sendRecoveryToken(
  String email,
  String userName,
  String token,
) async {
  final host = env['SMTP_HOST'];
  final username = env['SMTP_USER'];
  final password = env['SMTP_PASSWORD'];
  if (host == null || username == null || password == null) {
    throw StateError(
      'Configure SMTP_HOST, SMTP_USER e SMTP_PASSWORD para enviar tokens.',
    );
  }

  final smtpServer = SmtpServer(
    host,
    username: username,
    password: password,
    port: int.tryParse(env['SMTP_PORT'] ?? '587') ?? 587,
    ssl: env['SMTP_SSL'] == 'true',
  );

  final message = Message()
    ..from = Address(username, 'SnapLock')
    ..recipients.add(email)
    ..subject = 'Token para redefinir sua senha'
    ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; background-color: #f4f4f7;">
        <div style="background-color: #ffffff; border-radius: 8px; padding: 32px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
          <h2 style="color: #1a1a1a; margin-top: 0;">Olá, $userName!</h2>
          <p style="color: #444; font-size: 15px; line-height: 1.5;">
            Você solicitou a redefinição da sua senha. Use o código abaixo para continuar:
          </p>
          <div style="background-color: #f0f0f5; border-radius: 6px; padding: 16px; text-align: center; margin: 24px 0;">
            <span style="font-size: 28px; font-weight: bold; letter-spacing: 6px; color: #2b2b2b;">$token</span>
          </div>
          <p style="color: #666; font-size: 14px;">O código expira em <strong>15 minutos</strong>.</p>
          <p style="color: #666; font-size: 14px;">Não compartilhe este código com ninguém.</p>
          <p style="color: #999; font-size: 13px; margin-top: 24px;">
            Caso você não tenha feito essa solicitação, pode ignorar este e-mail com segurança.
          </p>
        </div>
      </div>
    ''';

  await send(message, smtpServer);
}
