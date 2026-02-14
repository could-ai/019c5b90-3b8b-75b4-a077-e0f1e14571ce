import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resume_model.dart';
import '../utils/analysis_utils.dart';
import '../widgets/resume_preview.dart';

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ResumeData _resumeData = ResumeData();
  String _selectedTemplate = 'classic';
  
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController(); // Comma separated

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTemplate();
    
    // Listeners to update state for analysis
    _nameController.addListener(() => setState(() => _resumeData.fullName = _nameController.text));
    _emailController.addListener(() => setState(() => _resumeData.email = _emailController.text));
    _phoneController.addListener(() => setState(() => _resumeData.phone = _phoneController.text));
    _summaryController.addListener(() => setState(() => _resumeData.summary = _summaryController.text));
    _skillsController.addListener(() {
      setState(() {
        _resumeData.skills = _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      });
    });
  }

  Future<void> _loadTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTemplate = prefs.getString('selected_template') ?? 'classic';
    });
  }

  Future<void> _saveTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_template', template);
    setState(() {
      _selectedTemplate = template;
    });
  }

  @override
  Widget build(BuildContext context) {
    final atsScore = AnalysisUtils.calculateATSScore(_resumeData);
    final improvements = AnalysisUtils.getImprovements(_resumeData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Resume Builder'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Preview')),
                    body: ResumePreview(data: _resumeData, template: _selectedTemplate),
                  ),
                ),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Experience'),
            Tab(text: 'Projects'),
            Tab(text: 'Template'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Analysis Bar
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ATS Score: $atsScore/100', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: atsScore > 70 ? Colors.green : (atsScore > 40 ? Colors.orange : Colors.red)
                      )
                    ),
                    const Text('Top Improvements', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (improvements.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: improvements.map((i) => Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Expanded(child: Text(i, style: const TextStyle(fontSize: 12))),
                        ],
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildExperienceTab(),
                _buildProjectsTab(),
                _buildTemplateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(
            controller: _summaryController, 
            maxLines: 4, 
            decoration: const InputDecoration(labelText: 'Professional Summary', border: OutlineInputBorder(), hintText: 'Write 40+ words...')
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _skillsController, 
            maxLines: 2, 
            decoration: const InputDecoration(labelText: 'Skills (comma separated)', border: OutlineInputBorder(), hintText: 'Flutter, Dart, Firebase...')
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._resumeData.experience.asMap().entries.map((entry) {
          int idx = entry.key;
          ExperienceItem exp = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: exp.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    onChanged: (v) => setState(() => exp.role = v),
                  ),
                  TextFormField(
                    initialValue: exp.company,
                    decoration: const InputDecoration(labelText: 'Company'),
                    onChanged: (v) => setState(() => exp.company = v),
                  ),
                  TextFormField(
                    initialValue: exp.duration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    onChanged: (v) => setState(() => exp.duration = v),
                  ),
                  const SizedBox(height: 8),
                  const Text('Bullet Points', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...exp.bullets.asMap().entries.map((bEntry) {
                    int bIdx = bEntry.key;
                    String bullet = bEntry.value;
                    String? verbWarning = AnalysisUtils.checkBulletActionVerb(bullet);
                    String? metricWarning = AnalysisUtils.checkBulletMetrics(bullet);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: bullet,
                                onChanged: (v) => setState(() => exp.bullets[bIdx] = v),
                                decoration: const InputDecoration(hintText: '• Did X resulting in Y%...'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => exp.bullets.removeAt(bIdx)),
                            ),
                          ],
                        ),
                        if (verbWarning != null) 
                          Text(verbWarning, style: const TextStyle(color: Colors.orange, fontSize: 11, fontStyle: FontStyle.italic)),
                        if (metricWarning != null) 
                          Text(metricWarning, style: const TextStyle(color: Colors.blue, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    );
                  }),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Bullet'),
                    onPressed: () => setState(() => exp.bullets.add('')),
                  ),
                  TextButton(
                    child: const Text('Remove Job', style: TextStyle(color: Colors.red)),
                    onPressed: () => setState(() => _resumeData.experience.removeAt(idx)),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(
          onPressed: () => setState(() => _resumeData.experience.add(ExperienceItem())),
          child: const Text('Add Experience'),
        ),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._resumeData.projects.asMap().entries.map((entry) {
          int idx = entry.key;
          ProjectItem proj = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: proj.title,
                    decoration: const InputDecoration(labelText: 'Project Title'),
                    onChanged: (v) => setState(() => proj.title = v),
                  ),
                  const SizedBox(height: 8),
                  const Text('Bullet Points', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...proj.bullets.asMap().entries.map((bEntry) {
                    int bIdx = bEntry.key;
                    String bullet = bEntry.value;
                    String? verbWarning = AnalysisUtils.checkBulletActionVerb(bullet);
                    String? metricWarning = AnalysisUtils.checkBulletMetrics(bullet);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: bullet,
                                onChanged: (v) => setState(() => proj.bullets[bIdx] = v),
                                decoration: const InputDecoration(hintText: '• Built X using Y...'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => proj.bullets.removeAt(bIdx)),
                            ),
                          ],
                        ),
                        if (verbWarning != null) 
                          Text(verbWarning, style: const TextStyle(color: Colors.orange, fontSize: 11, fontStyle: FontStyle.italic)),
                        if (metricWarning != null) 
                          Text(metricWarning, style: const TextStyle(color: Colors.blue, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    );
                  }),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Bullet'),
                    onPressed: () => setState(() => proj.bullets.add('')),
                  ),
                  TextButton(
                    child: const Text('Remove Project', style: TextStyle(color: Colors.red)),
                    onPressed: () => setState(() => _resumeData.projects.removeAt(idx)),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(
          onPressed: () => setState(() => _resumeData.projects.add(ProjectItem())),
          child: const Text('Add Project'),
        ),
      ],
    );
  }

  Widget _buildTemplateTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Choose Template', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTemplateOption('Classic', 'Traditional, serif fonts, elegant.', 'classic'),
        _buildTemplateOption('Modern', 'Clean, sans-serif, bold headers.', 'modern'),
        _buildTemplateOption('Minimal', 'Simple, spacious, light fonts.', 'minimal'),
      ],
    );
  }

  Widget _buildTemplateOption(String title, String desc, String value) {
    bool isSelected = _selectedTemplate == value;
    return Card(
      color: isSelected ? Colors.black : Colors.white,
      child: ListTile(
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: TextStyle(color: isSelected ? Colors.grey[300] : Colors.grey[600])),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.white) : const Icon(Icons.circle_outlined),
        onTap: () => _saveTemplate(value),
      ),
    );
  }
}
