import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

class DatabaseConfig {
  static Database? _db;

  static Database get db {
    if (_db == null) {
      throw StateError('O banco de dados não foi inicializado. Chame DatabaseConfig.init() primeiro.');
    }
    return _db!;
  }

  static void init({String? dbPath}) {
    final String path = dbPath ?? p.join(Directory.current.path, 'snaplock.db');
    print('📦 Inicializando banco de dados SQLite em: $path');

    _db = sqlite3.open(path);

    // Habilita checagem de chaves estrangeiras e modo WAL
    _db!.execute('PRAGMA foreign_keys = ON;');
    _db!.execute('PRAGMA journal_mode = WAL;');

    _createTables();
    print('✅ Banco de dados SQLite inicializado com sucesso.');
  }

  static void _createTables() {
    // Tabela de Usuários (RN01, RN04, RN06, RN08, RN10, RN17)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        bio TEXT DEFAULT '',
        gender TEXT DEFAULT '',
        avatar_url TEXT DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    // Tabela de Recuperação de Senha (RN05)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS password_resets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        last_sent_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de Amizades (RN13, RN17, RF10, RF14)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS friendships (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        friend_id TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('PENDING', 'ACCEPTED')),
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, friend_id)
      );
    ''');

    // Tabela de Publicações / Fotos (RN02, RN09, RN10, RF08, RF09)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        caption TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de Reações / Curtidas (RN16, RF13) - Apenas 1 reação por usuário por postagem
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS reactions (
        id TEXT PRIMARY KEY,
        post_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        reaction_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(post_id, user_id)
      );
    ''');

    // Tabela de Denúncias de Publicações (RN11, RF11)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id TEXT PRIMARY KEY,
        post_id TEXT NOT NULL,
        reporter_id TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING', 'REVIEWED', 'DISMISSED', 'ACTIONED')),
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de Dumps Mensais (RN15, RF12)
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS monthly_dumps (
        id TEXT PRIMARY KEY,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        post_count INTEGER NOT NULL,
        generated_at TEXT NOT NULL,
        UNIQUE(year, month)
      );
    ''');
  }

  static void close() {
    _db?.dispose();
    _db = null;
  }
}
