import 'package:flutter/material.dart';

class ProgrammingLanguageModel {
  final String name;
  final String
      iconPath; // Keep for fallback or remove if unused, but let's keep it for now
  final String logoUrl; // New field for network SVG
  final Color color;
  final String description;

  ProgrammingLanguageModel({
    required this.name,
    required this.iconPath,
    required this.logoUrl,
    required this.color,
    required this.description,
  });
}

// Using Devicon SVGs for high quality logos
final List<ProgrammingLanguageModel> allProgrammingLanguages = [
  ProgrammingLanguageModel(
    name: 'Python',
    iconPath: 'assets/icons/python.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/python/python-original.svg',
    color: const Color(0xFF3776AB),
    description: 'Great for AI, Data Science, and Web Dev.',
  ),
  ProgrammingLanguageModel(
    name: 'JavaScript',
    iconPath: 'assets/icons/javascript.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/javascript/javascript-original.svg',
    color: const Color(0xFFF7DF1E),
    description: 'The language of the web.',
  ),
  ProgrammingLanguageModel(
    name: 'Java',
    iconPath: 'assets/icons/java.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/java/java-original.svg',
    color: const Color(0xFF007396),
    description: 'Enterprise-grade backend systems.',
  ),
  ProgrammingLanguageModel(
    name: 'C++',
    iconPath: 'assets/icons/cpp.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/cplusplus/cplusplus-original.svg',
    color: const Color(0xFF00599C),
    description: 'High-performance applications.',
  ),
  ProgrammingLanguageModel(
    name: 'Dart',
    iconPath: 'assets/icons/dart.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/dart/dart-original.svg',
    color: const Color(0xFF0175C2),
    description: 'Optimized for UI (Flutter).',
  ),
  ProgrammingLanguageModel(
    name: 'Go',
    iconPath: 'assets/icons/go.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/go/go-original-wordmark.svg',
    color: const Color(0xFF00ADD8),
    description: 'Scalable cloud services.',
  ),
  ProgrammingLanguageModel(
    name: 'Swift',
    iconPath: 'assets/icons/swift.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/swift/swift-original.svg',
    color: const Color(0xFFFA7343),
    description: 'iOS and macOS development.',
  ),
  ProgrammingLanguageModel(
    name: 'Kotlin',
    iconPath: 'assets/icons/kotlin.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/kotlin/kotlin-original.svg',
    color: const Color(0xFF7F52FF),
    description: 'Modern Android development.',
  ),
  ProgrammingLanguageModel(
    name: 'Rust',
    iconPath: 'assets/icons/rust.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/rust/rust-original.svg',
    color: const Color(0xFFDEA584),
    description: 'Safety and performance.',
  ),
  ProgrammingLanguageModel(
    name: 'TypeScript',
    iconPath: 'assets/icons/typescript.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/typescript/typescript-original.svg',
    color: const Color(0xFF3178C6),
    description: 'JavaScript with syntax for types.',
  ),
  ProgrammingLanguageModel(
    name: 'PHP',
    iconPath: 'assets/icons/php.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/php/php-original.svg',
    color: const Color(0xFF777BB4),
    description: 'Server-side scripting.',
  ),
  ProgrammingLanguageModel(
    name: 'Ruby',
    iconPath: 'assets/icons/ruby.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/ruby/ruby-original.svg',
    color: const Color(0xFFCC342D),
    description: 'Simple and productive.',
  ),
  ProgrammingLanguageModel(
    name: 'SQL',
    iconPath: 'assets/icons/sql.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/mysql/mysql-original.svg',
    color: const Color(0xFF4479A1),
    description: 'Database management.',
  ),
  ProgrammingLanguageModel(
    name: 'HTML/CSS',
    iconPath: 'assets/icons/html.png',
    logoUrl:
        'https://raw.githubusercontent.com/devicons/devicon/master/icons/html5/html5-original.svg',
    color: const Color(0xFFE34F26),
    description: 'Building blocks of the web.',
  ),
];
