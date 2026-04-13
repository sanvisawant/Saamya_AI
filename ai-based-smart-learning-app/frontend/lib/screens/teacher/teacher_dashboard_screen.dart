import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/teacher_mock_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/accessibility_provider.dart';
import '../../utils/tr.dart';
import '../auth/login_screen.dart';
import '../student/ai_chatbot.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _teacherName = 'Teacher';
  
  // Controllers for Upload Material
  final _uploadTitleController = TextEditingController();
  final _uploadDescController = TextEditingController();
  final _uploadContentController = TextEditingController();
  String _uploadBoard = 'CBSE';
  String _uploadSubject = 'Mathematics';

  // Controllers for Quiz Creator
  final _quizTitleController = TextEditingController();
  final _quizTopicController = TextEditingController();
  String _quizBoard = 'CBSE';
  final List<Map<String, dynamic>> _quizQuestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTeacherInfo();
  }

  Future<void> _loadTeacherInfo() async {
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _teacherName = name);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uploadTitleController.dispose();
    _uploadDescController.dispose();
    _uploadContentController.dispose();
    _quizTitleController.dispose();
    _quizTopicController.dispose();
    super.dispose();
  }

  // --- Actions ---

  void _handleUpload() {
    if (_uploadTitleController.text.isEmpty || _uploadContentController.text.isEmpty) {
      _showSnack('Please fill in required fields');
      return;
    }

    TeacherMockService.addMaterial(
      title: _uploadTitleController.text.trim(),
      board: _uploadBoard,
      subject: _uploadSubject,
      description: _uploadDescController.text.trim(),
      contentText: _uploadContentController.text.trim(),
    );

    _uploadTitleController.clear();
    _uploadDescController.clear();
    _uploadContentController.clear();
    
    _showSnack('Material uploaded successfully!', isSuccess: true);
    setState(() {}); // Refresh list
    _tabController.animateTo(2); // Go to Content Library
  }

  void _addQuizQuestion() {
    setState(() {
      _quizQuestions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctIndex': 0,
      });
    });
  }

  void _handleCreateQuiz() {
    if (_quizTitleController.text.isEmpty || _quizQuestions.isEmpty) {
      _showSnack('Please add a title and at least one question');
      return;
    }

    TeacherMockService.addQuiz(
      title: _quizTitleController.text.trim(),
      board: _quizBoard,
      topic: _quizTopicController.text.trim(),
      questions: List.from(_quizQuestions),
    );

    _quizTitleController.clear();
    _quizTopicController.clear();
    _quizQuestions.clear();

    _showSnack('Quiz created successfully!', isSuccess: true);
    setState(() {});
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? const Color(0xFF2E7D32) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    final a11y = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.brandPrimary,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_teacherName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Teacher Console'.tr(context), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Language Switcher
          _buildLanguageToggle(a11y),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbot())),
            tooltip: 'Saamya Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.brandPrimary,
          unselectedLabelColor: AppTheme.textTertiary,
          indicatorColor: AppTheme.brandPrimary,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Overview'.tr(context)),
            Tab(text: 'Classroom'.tr(context)),
            Tab(text: 'Upload'.tr(context)),
            Tab(text: 'Quiz Creator'.tr(context)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildClassroomTab(),
          _buildUploadTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(AccessibilityProvider a11y) {
    final isHindi = a11y.language == 'hi';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => a11y.setLanguage('en'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isHindi ? AppTheme.brandPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('EN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: !isHindi ? Colors.white : AppTheme.textTertiary)),
            ),
          ),
          GestureDetector(
            onTap: () => a11y.setLanguage('hi'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isHindi ? AppTheme.brandPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('हिं', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isHindi ? Colors.white : AppTheme.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,'.tr(context), style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          Text(_teacherName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Students', '156', Icons.groups, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Inclusivity Score', '94%', Icons.verified_user, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard('Active Assignments', '12', Icons.assignment, Colors.orange),
          const SizedBox(height: 32),
          Text('Recent Content'.tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...TeacherMockService.getMaterials().take(3).map((m) => _buildMaterialTile(m)),
        ],
      ),
    );
  }

  Widget _buildClassroomTab() {
     final List<Map<String, dynamic>> students = [
      {'name': 'Sanvi Sawant', 'board': 'CBSE', 'mode': 'Visual Mode', 'progress': 0.85},
      {'name': 'Rahul Sharma', 'board': 'ICSE', 'mode': 'Auditory', 'progress': 0.72},
      {'name': 'Arjun Singh', 'board': 'CBSE', 'mode': 'Standard', 'progress': 0.94},
      {'name': 'Priya Das', 'board': 'SSC', 'mode': 'Standard', 'progress': 0.65},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: students.length,
      itemBuilder: (context, i) {
        final s = students[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
              child: Text(s['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
            ),
            title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildBadge(s['board'], Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadge(s['mode'], Colors.purple),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: s['progress'], backgroundColor: Colors.grey.shade100, color: AppTheme.brandPrimary, minHeight: 4),
                ),
              ],
            ),
            trailing: IconButton(icon: const Icon(Icons.send, size: 18), onPressed: () => _showSnack('Nudge sent!')),
          ),
        );
      },
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload New Material', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Share board-specific content with your students.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          _buildInputLabel('Title'),
          TextField(controller: _uploadTitleController, decoration: _inputStyle('e.g., Photosynthesis & Plant Cells')),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Target Board'),
                    _buildBoardDropdown(
                      value: _uploadBoard, 
                      onChanged: (v) => setState(() => _uploadBoard = v!)
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Subject'),
                    _buildSubjectDropdown(
                      value: _uploadSubject, 
                      onChanged: (v) => setState(() => _uploadSubject = v!)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputLabel('Description'),
          TextField(controller: _uploadDescController, decoration: _inputStyle('Brief summary...')),
          const SizedBox(height: 20),
          _buildInputLabel('Content Text'),
          TextField(
            controller: _uploadContentController, 
            maxLines: 8, 
            decoration: _inputStyle('Paste the full lesson content here...').copyWith(
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Publish Material', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _buildInputLabel('Quiz Title'),
          TextField(controller: _quizTitleController, decoration: _inputStyle('e.g., Science Weekly Test')),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildInputLabel('Board'),
                _buildBoardDropdown(value: _quizBoard, onChanged: (v) => setState(() => _quizBoard = v!)),
              ])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildInputLabel('Topic'),
                TextField(controller: _quizTopicController, decoration: _inputStyle('e.g., Biology')),
              ])),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...List.generate(_quizQuestions.length, (index) => _buildQuestionCard(index)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addQuizQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Add Question'),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleCreateQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save & Publish Quiz', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-widgets ---

  Widget _buildQuestionCard(int index) {
    final q = _quizQuestions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => q['question'] = v,
            decoration: _inputStyle('Question ${index + 1}'),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (optIdx) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: optIdx,
                  groupValue: q['correctIndex'],
                  onChanged: (v) => setState(() => q['correctIndex'] = v!),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (v) => q['options'][optIdx] = v,
                    decoration: _inputStyle('Option ${optIdx + 1}'),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMaterialTile(MockMaterial m) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: m.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(m.icon, color: m.color, size: 22),
        ),
        title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Row(
          children: [
            Text(m.subject, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: m.color)),
            const SizedBox(width: 8),
            Text(m.board, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(title.tr(context), style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textTertiary, letterSpacing: 1.5)),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildBoardDropdown({required String value, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: ['CBSE', 'ICSE', 'SSC'].map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown({required String value, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: ['Mathematics', 'Science', 'History', 'English', 'Social Studies']
              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
