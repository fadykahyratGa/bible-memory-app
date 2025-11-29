import 'package:supabase_flutter/supabase_flutter.dart';

/// ضع بيانات الاتصال بمشروع Supabase هنا.
/// Example SQL schema (execute in Supabase SQL editor):
/// ```sql
/// create table books (
///   id text primary key,
///   name_ar text not null,
///   chapters_count int not null
/// );
/// create table verses (
///   id text primary key,
///   book_id text references books(id),
///   chapter int not null,
///   verse_number int not null,
///   text_ar text not null
/// );
/// create table users (
///   id uuid primary key default uuid_generate_v4(),
///   created_at timestamptz default now()
/// );
/// create table user_progress (
///   user_id uuid primary key references users(id),
///   total_verses_completed int default 0,
///   total_games_played int default 0,
///   total_score int default 0,
///   current_level int default 1,
///   last_game_config jsonb
/// );
/// create table favorites (
///   user_id uuid references users(id),
///   verse_id text references verses(id),
///   primary key (user_id, verse_id)
/// );
/// create table badges (
///   id text primary key,
///   name_ar text not null,
///   description_ar text not null,
///   icon_key text not null,
///   condition_type text not null,
///   condition_value int not null
/// );
/// create table user_badges (
///   user_id uuid references users(id),
///   badge_id text references badges(id),
///   unlocked_at timestamptz default now(),
///   primary key (user_id, badge_id)
/// );
/// create table settings (
///   user_id uuid primary key references users(id),
///   default_difficulty text,
///   sound_enabled bool
/// );
/// ```
class SupabaseClientProvider {
  static const supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
  static const supabaseAnonKey = 'YOUR-ANON-KEY';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> ensureAnonymousUser() async {
    final session = client.auth.currentSession;
    if (session != null) return;
    await client.auth.signInAnonymously();
  }
}
