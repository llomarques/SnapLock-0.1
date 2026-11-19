import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'backend_config.dart';

Future<void> sendSignupVerificationEmail(
  String email,
  String userName,
  String token,
) async {
  if (!RegExp(r'^\d{6}$').hasMatch(token)) {
    throw ArgumentError.value(token, 'token', 'Deve conter seis dígitos.');
  }

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
    ..subject = 'Confirme seu e-mail para criar sua conta SnapLock'
    ..text = '''
Olá, $userName!

Para confirmar seu e-mail e criar sua conta SnapLock, informe este código no aplicativo:
$token

O código expira em 15 minutos. Se você não iniciou este cadastro, ignore esta mensagem.
'''
    ..html = _emailLayout(
      eyebrow: 'Confirmação de cadastro',
      content: '''
        <h1 style="margin:0 0 12px;color:#3E3A36;font-family:Georgia,'Times New Roman',serif;font-size:27px;line-height:1.25;">Olá, ${_escapeHtml(userName)}!</h1>
        <p style="margin:0;color:#6E6760;font-size:15px;line-height:1.7;">Falta só confirmar seu e-mail para criar sua conta no SnapLock. Digite este código no aplicativo:</p>
        <div style="margin:24px 0;padding:16px;background-color:#EADCCE;border:1px solid #D8C7B2;border-radius:14px;text-align:center;">
          <span style="color:#5E3023;font-size:30px;font-weight:bold;letter-spacing:8px;">${_escapeHtml(token)}</span>
        </div>
        <p style="margin:0;color:#6E6760;font-size:13px;line-height:1.6;">O código expira em <strong style="color:#3E3A36;">15 minutos</strong>. Se você não iniciou este cadastro, ignore esta mensagem; nenhuma conta será criada.</p>
      ''',
    );

  await send(message, smtpServer);
}

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
    ..html = _emailLayout(
      eyebrow: 'Segurança da conta',
      content: '''
        <h1 style="margin:0 0 12px;color:#3E3A36;font-family:Georgia,'Times New Roman',serif;font-size:27px;line-height:1.25;">Olá, ${_escapeHtml(userName)}!</h1>
        <p style="margin:0;color:#6E6760;font-size:15px;line-height:1.7;">Você solicitou a redefinição da sua senha. Use o código abaixo para continuar:</p>
        <div style="margin:24px 0;padding:16px;background-color:#EADCCE;border:1px solid #D8C7B2;border-radius:14px;text-align:center;">
          <span style="color:#5E3023;font-size:28px;font-weight:bold;letter-spacing:6px;">${_escapeHtml(token)}</span>
        </div>
        <p style="margin:0 0 10px;color:#6E6760;font-size:14px;line-height:1.6;">O código expira em <strong style="color:#3E3A36;">15 minutos</strong>. Não compartilhe este código com ninguém.</p>
        <p style="margin:20px 0 0;color:#6E6760;font-size:13px;line-height:1.6;">Caso você não tenha feito essa solicitação, pode ignorar este e-mail com segurança.</p>
      ''',
    );

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
    ..html = _emailLayout(
      eyebrow: 'Confirmação de e-mail',
      content: '''
        <h1 style="margin:0 0 12px;color:#3E3A36;font-family:Georgia,'Times New Roman',serif;font-size:27px;line-height:1.25;">Olá, ${_escapeHtml(userName)}!</h1>
        <p style="margin:0;color:#6E6760;font-size:15px;line-height:1.7;">Use o código abaixo para confirmar este endereço como seu novo e-mail no SnapLock:</p>
        <div style="margin:24px 0;padding:16px;background-color:#EADCCE;border:1px solid #D8C7B2;border-radius:14px;text-align:center;">
          <span style="color:#5E3023;font-size:28px;font-weight:bold;letter-spacing:6px;">${_escapeHtml(token)}</span>
        </div>
        <p style="margin:0 0 10px;color:#6E6760;font-size:14px;line-height:1.6;">O código expira em <strong style="color:#3E3A36;">15 minutos</strong>.</p>
        <p style="margin:20px 0 0;color:#6E6760;font-size:13px;line-height:1.6;">Se você não solicitou esta alteração, ignore este e-mail. Seu endereço atual não será alterado.</p>
      ''',
    );

  await send(message, smtpServer);
}

Future<void> sendPostDeactivationNotice(
  String email,
  String userName,
  String postDate,
  int postId,
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

Sua publicação de ID $postId, postada em $postDate, foi desativada no SnapLock após receber denúncias.

Ela não está mais visível na plataforma. Se você acredita que houve um engano,
entre em contato com a equipe do SnapLock.

Esta mensagem é um aviso automático. Não responda a este e-mail.
'''
    ..html = _emailLayout(
      eyebrow: 'Aviso sobre sua publicação',
      content: '''
        <div style="display:inline-block;padding:7px 12px;border-radius:20px;background-color:#EADCCE;color:#895737;font-size:11px;font-weight:bold;letter-spacing:1px;text-transform:uppercase;">Revisão da comunidade</div>
        <h1 style="margin:20px 0 12px;color:#3E3A36;font-family:Georgia,'Times New Roman',serif;font-size:27px;line-height:1.25;">Olá, ${_escapeHtml(userName)}.</h1>
        <p style="margin:0;color:#6E6760;font-size:15px;line-height:1.7;">Sua publicação recebeu denúncias da comunidade e foi desativada automaticamente, conforme as regras da plataforma.</p>
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:24px 0;background-color:#F3E9DC;border:1px solid #D8C7B2;border-radius:14px;">
          <tr>
            <td style="padding:18px 20px;color:#3E3A36;font-size:14px;line-height:1.8;">
              <strong>ID da publicação:</strong> $postId<br>
              <strong>Data da publicação:</strong> ${_escapeHtml(postDate)}
            </td>
          </tr>
        </table>
        <p style="margin:0;color:#3E3A36;font-size:14px;line-height:1.7;">A publicação não está mais visível. Se você acredita que houve um engano, entre em contato com a equipe do SnapLock informando o ID da publicação para solicitar uma análise.</p>
        <p style="margin:24px 0 0;color:#6E6760;font-size:13px;line-height:1.6;">Esta é uma notificação automática. Por favor, não responda a este e-mail.</p>
      ''',
    );

  await send(message, smtpServer);
}

String _emailLayout({required String eyebrow, required String content}) => '''
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
                <div style="margin-top:7px;color:#EADCCE;font-size:11px;letter-spacing:2px;text-transform:uppercase;">${_escapeHtml(eyebrow)}</div>
              </td>
            </tr>
            <tr>
              <td style="padding:32px;">$content</td>
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

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
