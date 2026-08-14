import 'package:test/test.dart';
import '../lib/config/database.dart';
import '../lib/utils/age_calculator.dart';
import '../lib/utils/password_validator.dart';
import '../lib/services/profanity_filter_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/friend_service.dart';
import '../lib/services/post_service.dart';
import '../lib/services/reaction_service.dart';
import '../lib/services/report_service.dart';
import '../lib/services/dump_scheduler_service.dart';

void main() {
  setUpAll(() {
    // Uses an in-memory SQLite database for testing
    DatabaseConfig.init(dbPath: ':memory:');
  });

  tearDownAll(() {
    DatabaseConfig.close();
  });

  group('RN07 - Validação de Senha', () {
    test('Rejeita senhas curtas (< 8 caracteres)', () {
      expect(PasswordValidator.validate('Ab1@567'), isNotNull);
    });

    test('Rejeita senhas sem maiúscula', () {
      expect(PasswordValidator.validate('abc1234@'), isNotNull);
    });

    test('Rejeita senhas sem minúscula', () {
      expect(PasswordValidator.validate('ABC1234@'), isNotNull);
    });

    test('Rejeita senhas sem número', () {
      expect(PasswordValidator.validate('Abcdefgh@'), isNotNull);
    });

    test('Rejeita senhas sem caractere especial', () {
      expect(PasswordValidator.validate('Abcdefg1'), isNotNull);
    });

    test('Aceita senha válida com todos os requisitos', () {
      expect(PasswordValidator.validate('SenhaSegura123@'), isNull);
    });
  });

  group('RN01 - Validação de Idade (>= 16 anos)', () {
    test('Permite usuário com 16 anos ou mais', () {
      final validBirthdate = DateTime(2005, 5, 20);
      expect(AgeCalculator.isAtLeast16(validBirthdate), isTrue);
    });

    test('Bloqueia usuário com menos de 16 anos', () {
      final youngBirthdate = DateTime(2020, 1, 1);
      expect(AgeCalculator.isAtLeast16(youngBirthdate), isFalse);
    });
  });

  group('Moderação de Legendas - ProfanityFilterService', () {
    test('Detecta e censura palavras impróprias em legendas', () {
      const text = 'Esta foto é bacana mas contém palavra_impropria!';
      expect(ProfanityFilterService.hasProfanity(text), isTrue);

      final filtered = ProfanityFilterService.filter(text);
      expect(filtered.contains('palavra_impropria'), isFalse);
      expect(filtered.contains('*' * 17), isTrue);
    });
  });

  group('Fluxo Completo de Autenticação e Regras de Negócio', () {
    late String user1Id;
    late String user2Id;

    test('RN04, RN08, RF02 - Registro de Usuários', () {
      final res1 = AuthService.register(
        name: 'Lorena Silva',
        email: 'lorena@snaplock.com',
        password: 'Password123@',
        confirmPassword: 'Password123@',
        birthdate: '2004-03-15',
        bio: 'P.O do projeto SnapLock',
      );

      final user1 = res1['user'] as Map<String, dynamic>;
      user1Id = user1['id'] as String;
      expect(user1['email'], equals('lorena@snaplock.com'));

      final res2 = AuthService.register(
        name: 'Isabella Leite',
        email: 'isabella@snaplock.com',
        password: 'Password123@',
        confirmPassword: 'Password123@',
        birthdate: '2005-08-10',
        bio: 'Scrum Master SnapLock',
      );

      final user2 = res2['user'] as Map<String, dynamic>;
      user2Id = user2['id'] as String;
      expect(user2['email'], equals('isabella@snaplock.com'));

      // Tentar registrar com email duplicado (RN08) deve falhar
      expect(
        () => AuthService.register(
          name: 'Lorena Duplicada',
          email: 'lorena@snaplock.com',
          password: 'Password123@',
          confirmPassword: 'Password123@',
          birthdate: '2002-01-01',
        ),
        throwsFormatException,
      );
    });

    test('RN06, RF01 - Login', () {
      final loginRes = AuthService.login('lorena@snaplock.com', 'Password123@');
      final user = loginRes['user'] as Map<String, dynamic>;
      expect(user['id'], equals(user1Id));
    });

    test('RN13, RF10 - Feed Privado e Sistema de Amizade', () {
      // Antes de ser amigo: post de User1 não aparece no feed do User2
      final post = PostService.createPost(
        userId: user1Id,
        imageBytes: [1, 2, 3, 4],
        originalFileName: 'foto1.jpg',
        caption: 'Minha foto secreta com amigos!',
      );

      final feedUser2Before = PostService.getFeed(user2Id);
      expect(feedUser2Before.any((p) => p.id == post.id), isFalse);

      // Solicitar e aceitar amizade
      FriendService.sendRequest(user2Id, user1Id);
      final pending = FriendService.getPendingRequests(user1Id);
      expect(pending.length, equals(1));

      final reqId = pending.first['requestId'] as String;
      FriendService.acceptRequest(user1Id, reqId);

      // Após aceitar amizade: post de User1 agora aparece no feed de User2 (RN13)
      final feedUser2After = PostService.getFeed(user2Id);
      expect(feedUser2After.any((p) => p.id == post.id), isTrue);
    });

    test('RN16, RF13 - Reações (1 por publicação)', () {
      final feed = PostService.getFeed(user2Id);
      final post = feed.first;

      // Adiciona reação HEART
      ReactionService.setReaction(postId: post.id, userId: user2Id, reactionType: 'HEART');
      var reactions = ReactionService.getPostReactions(post.id);
      expect(reactions.length, equals(1));
      expect(reactions.first.reactionType, equals('HEART'));

      // Atualiza reação para FIRE (substitui a anterior por ter chave única post_id + user_id)
      ReactionService.setReaction(postId: post.id, userId: user2Id, reactionType: 'FIRE');
      reactions = ReactionService.getPostReactions(post.id);
      expect(reactions.length, equals(1));
      expect(reactions.first.reactionType, equals('FIRE'));
    });

    test('RN11, RF11 - Denúncias', () {
      final feed = PostService.getFeed(user2Id);
      final post = feed.first;

      final report = ReportService.reportPost(
        postId: post.id,
        reporterId: user2Id,
        reason: 'Violação dos termos de uso',
      );

      expect(report.status, equals('PENDING'));
    });

    test('RN15, RF12 - Dump Mensal', () {
      final now = DateTime.now();
      final dump = DumpSchedulerService.generateMonthlyDump(now.year, now.month);
      expect(dump.postCount, greaterThanOrEqualTo(1));
    });

    test('RN10, RF07 - Exclusão de Conta em Cascata', () {
      AuthService.deleteAccount(user1Id);

      // Tentativa de login após exclusão falha
      expect(
        () => AuthService.login('lorena@snaplock.com', 'Password123@'),
        throwsFormatException,
      );
    });
  });
}
