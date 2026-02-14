import 'package:flutter/material.dart';
import '../models/resume_model.dart';

class AnalysisUtils {
  static const List<String> actionVerbs = [
    'Built', 'Developed', 'Designed', 'Implemented', 'Led', 'Improved', 
    'Created', 'Optimized', 'Automated', 'Managed', 'Orchestrated', 
    'Engineered', 'Spearheaded', 'Launched', 'Architected', 'Deployed',
    'Reduced', 'Increased', 'Saved', 'Generated'
  ];

  static String? checkBulletActionVerb(String bullet) {
    if (bullet.trim().isEmpty) return null;
    final firstWord = bullet.trim().split(' ').first;
    // Simple check: is the first word in our list (case insensitive)?
    // Or does it end in 'ed'? (heuristic)
    bool startsWithVerb = actionVerbs.any((v) => v.toLowerCase() == firstWord.toLowerCase());
    
    if (!startsWithVerb) {
      return "Start with a strong action verb (e.g., Built, Led, Optimized).";
    }
    return null;
  }

  static String? checkBulletMetrics(String bullet) {
    if (bullet.trim().isEmpty) return null;
    // Check for numbers, %, $, k, M
    final hasMetrics = RegExp(r'[0-9]+|%|\$').hasMatch(bullet);
    if (!hasMetrics) {
      return "Add measurable impact (numbers, %, \$).";
    }
    return null;
  }

  static int calculateATSScore(ResumeData data) {
    int score = 0;
    
    // Basic Info
    if (data.fullName.isNotEmpty) score += 10;
    if (data.email.isNotEmpty) score += 5;
    if (data.phone.isNotEmpty) score += 5;
    
    // Summary
    if (data.summary.split(' ').length >= 40) score += 15;
    else if (data.summary.isNotEmpty) score += 5;

    // Experience
    if (data.experience.isNotEmpty) score += 20;
    if (data.experience.length >= 2) score += 10;

    // Projects
    if (data.projects.isNotEmpty) score += 15;
    if (data.projects.length >= 2) score += 5;

    // Skills
    if (data.skills.length >= 5) score += 10;
    if (data.skills.length >= 8) score += 5;

    return score.clamp(0, 100);
  }

  static List<String> getImprovements(ResumeData data) {
    List<String> improvements = [];

    if (data.projects.length < 2) {
      improvements.add("Add at least 2 projects to showcase your work.");
    }

    bool hasNumbers = false;
    for (var exp in data.experience) {
      for (var b in exp.bullets) {
        if (RegExp(r'[0-9]+|%|\$').hasMatch(b)) hasNumbers = true;
      }
    }
    for (var proj in data.projects) {
      for (var b in proj.bullets) {
        if (RegExp(r'[0-9]+|%|\$').hasMatch(b)) hasNumbers = true;
      }
    }
    
    if (!hasNumbers && (data.experience.isNotEmpty || data.projects.isNotEmpty)) {
      improvements.add("Add measurable impact (numbers, %) to your bullets.");
    }

    if (data.summary.isNotEmpty && data.summary.split(' ').length < 40) {
      improvements.add("Expand summary to 40+ words for better context.");
    }

    if (data.skills.length < 8) {
      improvements.add("List at least 8 key skills relevant to your role.");
    }

    if (data.experience.isEmpty) {
      improvements.add("Add internships or work history to boost credibility.");
    }

    return improvements.take(3).toList();
  }
}
