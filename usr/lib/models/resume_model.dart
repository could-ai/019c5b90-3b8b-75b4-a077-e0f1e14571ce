import 'dart:convert';

class ResumeData {
  String fullName;
  String email;
  String phone;
  String summary;
  List<ExperienceItem> experience;
  List<ProjectItem> projects;
  List<String> skills;
  String education;

  ResumeData({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.summary = '',
    this.experience = const [],
    this.projects = const [],
    this.skills = const [],
    this.education = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'summary': summary,
      'experience': experience.map((e) => e.toJson()).toList(),
      'projects': projects.map((e) => e.toJson()).toList(),
      'skills': skills,
      'education': education,
    };
  }

  factory ResumeData.fromJson(Map<String, dynamic> json) {
    return ResumeData(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      summary: json['summary'] ?? '',
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => ExperienceItem.fromJson(e))
              .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => ProjectItem.fromJson(e))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      education: json['education'] ?? '',
    );
  }
}

class ExperienceItem {
  String role;
  String company;
  String duration;
  List<String> bullets;

  ExperienceItem({
    this.role = '',
    this.company = '',
    this.duration = '',
    this.bullets = const [],
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'company': company,
        'duration': duration,
        'bullets': bullets,
      };

  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
        role: json['role'] ?? '',
        company: json['company'] ?? '',
        duration: json['duration'] ?? '',
        bullets: (json['bullets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class ProjectItem {
  String title;
  String description; // Usually bullets
  List<String> bullets;

  ProjectItem({
    this.title = '',
    this.description = '',
    this.bullets = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'bullets': bullets,
      };

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        bullets: (json['bullets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}
