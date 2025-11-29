# احفظ كلمة الله

تطبيق حفظ آيات الكتاب المقدس للأطفال باللغة العربية (اتجاه RTL) مبني بـ Flutter 3 / Dart 3 ويستخدم Supabase كقاعدة بيانات لجميع البيانات الدائمة.

## كيفية التهيئة والتشغيل
1. **إعداد Supabase**
   - أنشئ مشروعًا في [Supabase](https://supabase.com/).
   - أنشئ الجداول كما في أمثلة SQL داخل `lib/services/supabase_client_provider.dart` (يمكن تعديلها حسب الحاجة).
   - انسخ `SUPABASE_URL` و `SUPABASE_ANON_KEY` من إعدادات المشروع.
2. **تحديث القيم في الكود**
   - افتح `lib/services/supabase_client_provider.dart` وعدّل القيمتين `supabaseUrl` و `supabaseAnonKey`.
3. **تشغيل التطبيق**
   - تأكد من تثبيت Flutter 3/Dart 3.
   - شغّل: `flutter pub get` ثم `flutter run`.

## هيكلة المجلدات
انظر إلى شجرة `lib/` لمزيد من التفاصيل حول الطبقات (النماذج، الخدمات، المزودات، الواجهات).
