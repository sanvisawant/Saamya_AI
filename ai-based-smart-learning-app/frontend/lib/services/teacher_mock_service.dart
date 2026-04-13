import 'package:flutter/material.dart';

class MockMaterial {
  final String id;
  final String title;
  final String board;
  final String subject;
  final String description;
  final String contentText;
  final DateTime createdAt;
  final Color color;
  final IconData icon;

  MockMaterial({
    required this.id,
    required this.title,
    required this.board,
    required this.subject,
    required this.description,
    required this.contentText,
    required this.createdAt,
    this.color = Colors.blue,
    this.icon = Icons.book,
  });
}

class MockQuiz {
  final String id;
  final String title;
  final String board;
  final String topic;
  final List<Map<String, dynamic>> questions;
  final DateTime createdAt;

  MockQuiz({
    required this.id,
    required this.title,
    required this.board,
    required this.topic,
    required this.questions,
    required this.createdAt,
  });
}

class TeacherMockService {
  static final List<MockMaterial> _materials = [
    MockMaterial(
      id: '1',
      title: 'Introduction to Algebra',
      board: 'CBSE',
      subject: 'Mathematics',
      description: 'Foundational concepts of variables and equations.',
      contentText: 'Algebra is a branch of mathematics...',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      color: Colors.blue,
      icon: Icons.calculate,
    ),
    MockMaterial(
      id: '2',
      title: 'The Mughal Empire',
      board: 'SSC',
      subject: 'History',
      description: 'Overview of the Mughal dynasty in India.',
      contentText: 'The Mughal Empire was an early modern empire...',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      color: Colors.orange,
      icon: Icons.account_balance,
    ),
  ];

  static final List<MockQuiz> _quizzes = [];

  static List<MockMaterial> getMaterials() => _materials;
  static List<MockQuiz> getQuizzes() => _quizzes;

  static void addMaterial({
    required String title,
    required String board,
    required String subject,
    required String description,
    required String contentText,
  }) {
    _materials.insert(0, MockMaterial(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      board: board,
      subject: subject,
      description: description,
      contentText: contentText,
      createdAt: DateTime.now(),
      color: _getBoardColor(board),
      icon: _getSubjectIcon(subject),
    ));
  }

  static void addQuiz({
    required String title,
    required String board,
    required String topic,
    required List<Map<String, dynamic>> questions,
  }) {
    _quizzes.insert(0, MockQuiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      board: board,
      topic: topic,
      questions: questions,
      createdAt: DateTime.now(),
    ));
  }

  static Color _getBoardColor(String board) {
    switch (board) {
      case 'CBSE': return Colors.blue;
      case 'ICSE': return Colors.purple;
      case 'SSC': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  static IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate;
    if (s.contains('science')) return Icons.biotech;
    if (s.contains('history')) return Icons.history_edu;
    if (s.contains('english')) return Icons.menu_book;
    return Icons.assignment;
  }
}
