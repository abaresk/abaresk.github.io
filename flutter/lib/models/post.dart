class Post {
  final String slug;
  final String title;
  final DateTime date;
  final String section;

  const Post({
    required this.slug,
    required this.title,
    required this.date,
    required this.section,
  });

  factory Post.fromJson(Map<String, dynamic> json, String section) {
    return Post(
      slug: json['slug'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      section: section,
    );
  }

  String get monthDay {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String get fullDate {
    return '$monthDay, ${date.year}';
  }
}
