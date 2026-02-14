import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resume_model.dart';
import '../utils/analysis_utils.dart';

class ResumePreview extends StatelessWidget {
  final ResumeData data;
  final String template; // 'classic', 'modern', 'minimal'

  const ResumePreview({super.key, required this.data, required this.template});

  @override
  Widget build(BuildContext context) {
    // Determine styles based on template
    TextStyle? headerStyle;
    TextStyle? bodyStyle;
    MainAxisAlignment headerAlignment;
    bool showDividers;
    
    switch (template) {
      case 'modern':
        headerStyle = GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 24);
        bodyStyle = GoogleFonts.roboto(fontSize: 12);
        headerAlignment = MainAxisAlignment.start;
        showDividers = false;
        break;
      case 'minimal':
        headerStyle = GoogleFonts.lato(fontWeight: FontWeight.w300, fontSize: 28);
        bodyStyle = GoogleFonts.lato(fontSize: 11);
        headerAlignment = MainAxisAlignment.start;
        showDividers = false;
        break;
      case 'classic':
      default:
        headerStyle = GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 22);
        bodyStyle = GoogleFonts.merriweather(fontSize: 11);
        headerAlignment = MainAxisAlignment.center;
        showDividers = true;
        break;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: headerAlignment,
              children: [
                Column(
                  crossAxisAlignment: headerAlignment == MainAxisAlignment.center 
                      ? CrossAxisAlignment.center 
                      : CrossAxisAlignment.start,
                  children: [
                    Text(data.fullName.toUpperCase(), style: headerStyle),
                    const SizedBox(height: 8),
                    Text(
                      [data.email, data.phone, data.education].where((s) => s.isNotEmpty).join(' | '),
                      style: bodyStyle?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (showDividers) const Divider(thickness: 1, color: Colors.black),
            
            // Summary
            if (data.summary.isNotEmpty) ...[
              _SectionHeader(title: 'SUMMARY', template: template),
              Text(data.summary, style: bodyStyle),
              const SizedBox(height: 16),
            ],

            // Experience
            if (data.experience.isNotEmpty) ...[
              _SectionHeader(title: 'EXPERIENCE', template: template),
              ...data.experience.map((exp) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(exp.role, style: bodyStyle?.copyWith(fontWeight: FontWeight.bold)),
                        Text(exp.duration, style: bodyStyle?.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    Text(exp.company, style: bodyStyle?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    ...exp.bullets.map((b) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: bodyStyle),
                        Expanded(child: Text(b, style: bodyStyle)),
                      ],
                    )),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Projects
            if (data.projects.isNotEmpty) ...[
              _SectionHeader(title: 'PROJECTS', template: template),
              ...data.projects.map((proj) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(proj.title, style: bodyStyle?.copyWith(fontWeight: FontWeight.bold)),
                    if (proj.description.isNotEmpty)
                      Text(proj.description, style: bodyStyle?.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    ...proj.bullets.map((b) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: bodyStyle),
                        Expanded(child: Text(b, style: bodyStyle)),
                      ],
                    )),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Skills
            if (data.skills.isNotEmpty) ...[
              _SectionHeader(title: 'SKILLS', template: template),
              Text(data.skills.join(', '), style: bodyStyle),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String template;

  const _SectionHeader({required this.title, required this.template});

  @override
  Widget build(BuildContext context) {
    TextStyle? style;
    bool underline = false;

    switch (template) {
      case 'modern':
        style = GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2);
        underline = false;
        break;
      case 'minimal':
        style = GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2.0);
        underline = false;
        break;
      case 'classic':
      default:
        style = GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 14);
        underline = true;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: style),
          if (underline) const Divider(thickness: 1, color: Colors.black),
        ],
      ),
    );
  }
}
