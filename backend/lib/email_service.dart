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

Future<void> sendEmailChangeToken(
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
    ..subject = 'Confirme seu novo e-mail do SnapLock'
    ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; background-color: #f4f4f7;">
        <div style="background-color: #ffffff; border-radius: 8px; padding: 32px;">
          <h2 style="color: #1a1a1a; margin-top: 0;">Olá, $userName!</h2>
          <p style="color: #444; font-size: 15px; line-height: 1.5;">
            Use o código abaixo para confirmar este endereço como seu novo e-mail no SnapLock:
          </p>
          <div style="background-color: #f0f0f5; border-radius: 6px; padding: 16px; text-align: center; margin: 24px 0;">
            <span style="font-size: 28px; font-weight: bold; letter-spacing: 6px; color: #2b2b2b;">$token</span>
          </div>
          <p style="color: #666; font-size: 14px;">O código expira em <strong>15 minutos</strong>.</p>
          <p style="color: #999; font-size: 13px;">Se você não solicitou esta alteração, ignore este e-mail. Seu endereço atual não será alterado.</p>
        </div>
      </div>
    ''';

  await send(message, smtpServer);
}

Future<void> sendPostDeactivationNotice(
  String email,
  String userName,
  int postId,
  int reportCount,
) async {
  final host = env['SMTP_HOST'];
  final username = env['SMTP_USER'];
  final password = env['SMTP_PASSWORD'];
  if (host == null || username == null || password == null) {
    throw StateError(
      'Configure SMTP_HOST, SMTP_USER e SMTP_PASSWORD para enviar notificações.',
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
    ..subject = 'Sua publicação foi desativada no SnapLock'
    ..text = '''
Olá, $userName,

Sua publicação #$postId foi desativada no SnapLock após receber $reportCount denúncias.

Ela não está mais visível na plataforma. Se você acredita que houve um engano,
entre em contato com a equipe do SnapLock.

Esta mensagem é um aviso automático. Não responda a este e-mail.
'''
    ..html = '''
<!doctype html>
<html lang="pt-BR">
  <body style="margin:0;padding:0;background-color:#F3E9DC;font-family:Arial,Helvetica,sans-serif;color:#3E3A36;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#F3E9DC;padding:32px 12px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;background-color:#FFFFFF;border:1px solid #D8C7B2;border-radius:20px;overflow:hidden;">
            <tr>
              <td style="background-color:#5E3023;padding:26px 32px;text-align:center;">
                <div style="font-family:Georgia,'Times New Roman',serif;color:#F3E9DC;font-size:30px;font-weight:bold;letter-spacing:1px;">SnapLock</div>
                <div style="margin-top:7px;color:#EADCCE;font-size:11px;letter-spacing:2px;text-transform:uppercase;">Aviso sobre sua publicação</div>
              </td>
            </tr>
            <tr>
              <td style="padding:32px;">
                <div style="display:inline-block;padding:7px 12px;border-radius:20px;background-color:#F7E8DE;color:#895737;font-size:11px;font-weight:bold;letter-spacing:1px;text-transform:uppercase;">Revisão da comunidade</div>
                <h1 style="margin:20px 0 12px;color:#3E3A36;font-family:Georgia,'Times New Roman',serif;font-size:27px;line-height:1.25;">Olá, ${_escapeHtml(userName)}.</h1>
                <p style="margin:0;color:#6E6760;font-size:15px;line-height:1.7;">Sua publicação recebeu denúncias da comunidade e foi desativada automaticamente, conforme as regras da plataforma.</p>
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:24px 0;background-color:#F3E9DC;border:1px solid #D8C7B2;border-radius:14px;">
                  <tr>
                    <td style="padding:18px 20px;">
                      <div style="color:#6E6760;font-size:11px;font-weight:bold;letter-spacing:1px;text-transform:uppercase;">Resumo</div>
                      <div style="margin-top:10px;color:#3E3A36;font-size:14px;line-height:1.8;"><strong>Publicação:</strong> #$postId<br><strong>Denúncias recebidas:</strong> $reportCount</div>
                    </td>
                  </tr>
                </table>
                <p style="margin:0;color:#3E3A36;font-size:14px;line-height:1.7;">A publicação não está mais visível na plataforma. Se você acredita que houve um engano, entre em contato com a equipe do SnapLock para solicitar uma análise.</p>
                <p style="margin:24px 0 0;color:#6E6760;font-size:13px;line-height:1.6;">Esta é uma notificação automática. Por favor, não responda a este e-mail.</p>
              </td>
            </tr>
            <tr>
              <td style="padding:18px 32px;background-color:#F3E9DC;border-top:1px solid #D8C7B2;text-align:center;color:#6E6760;font-size:12px;">SnapLock · Compartilhe com cuidado</td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
''';

  await send(message, smtpServer);
}

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
