/// Step 5 — one-time seed data for the `courses` table.
///
/// The list below is the canonical course catalogue (Mongolian + English as
/// delivered by the business owner). Text is stored **exactly** as written:
/// no translating, no lowercasing, no re-spacing — Cyrillic must survive
/// byte-for-byte (SQLite stores UTF-8 natively, so nothing else is needed).
///
/// Seeding itself happens in `AppDatabase.migration.onCreate`
/// (see `database.dart` → `_seedCoursesIfEmpty()`), which is idempotent:
/// it only runs when the `courses` table is empty, so it is safe to leave in
/// place for every fresh install / test DB creation.
const List<String> kSeedCourseNames = [
  'счин (хос)',
  'Гоо сайхан',
  'Шивээс (хөмсөг, уруул, контр)',
  'Сормуус',
  'Бариа засал',
  'Гуаша',
  'Manicure',
  'Pedicure',
  'Вакс',
  'Makeup',
  'Оёдол & Эсгүүр',
  'Нягтлан Бодох Бүртгэл',
  'Архив & Албан Бичиг Хөтөлөлт',
  'Нярав',
  'Хүний нөөц',
  'Компьютер & Оффис хэрэглээ',
  'Худалдагч касс',
  'Зөөгч',
  'Бариста',
  'Бармен',
  'Бартендер',
  'Мужаан',
  'Сантехникч',
  'Цахилгаанчин',
  'Оосорлогч, дохиочин',
  'Цахилгаан холбооны техникч',
  'Барилгийн засал чимэглэлчин',
  'Барилгын шат угсралт',
  'Бетон арматурчин',
  'Тоног төхөөрөмжийн засварчин',
  'Автын засварчин',
  'Гар утасны засварчин',
  'Экскаваторын операторч',
  'Дампын операторч',
  'Ковшын операторч',
  'Автогрейдерын оператор',
  'Бульдозер операторч',
  'Замын индүүний операторч',
  'Сэрээт өргөгчийн операторч',
  'Сэрээ ачигчийн операторч',
  'Сагстай өргөгчийн операторч',
  'Хөвүүлэн баяжуулахын операторч',
  'Бетон зуурмагийн операторч',
  'Хүнд машин механизмын засвар',
  'Гагнуурчин',
  'ХАБЭА - Ажил олгогч, удирдах ажилтны сургалт',
  'ХАБЭА - Нийт ажилтны сургалт',
  'ХАБЭА - Дунд шатны удирдлагын сургалт',
  'ХАБЭА - Мэргэшүүлэх сургалт',
  'ХАБЭА - ҮО, ХХ-г судлан бүртгэх ОТББКомис чадавхжуулах сургалт',
  'ХАБЭА - Эрсдэлтэй ажлын байрны сургалт',
  'ХАБЭА - Тусгай сургалт',
  'ХАБЭА - Асуудал хариуцсан ажилтны сургалт',
];
