// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/models/app_user.dart';

class BugReport {
  final String id;
  final AppUser user;
  final String description;
  final String appVersion;
  final App app;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isResolved;
  final String? resolutionNotes;
  final String? screenshotUrl;
  BugReport({
    required this.id,
    required this.user,
    required this.description,
    required this.appVersion,
    required this.app,
    required this.createdAt,
    this.updatedAt,
    required this.isResolved,
    this.resolutionNotes,
    this.screenshotUrl,
  });

  BugReport copyWith({
    String? id,
    AppUser? user,
    String? description,
    String? appVersion,
    App? app,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isResolved,
    String? resolutionNotes,
    String? screenshotUrl,
  }) {
    return BugReport(
      id: id ?? this.id,
      user: user ?? this.user,
      description: description ?? this.description,
      appVersion: appVersion ?? this.appVersion,
      app: app ?? this.app,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isResolved: isResolved ?? this.isResolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
      'description': description,
      'appVersion': appVersion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isResolved': isResolved,
      'resolutionNotes': resolutionNotes,
      'screenshotUrl': screenshotUrl,
    };
  }

  factory BugReport.fromMap(Map<String, dynamic> map, {required App app}) {
    return BugReport(
      app: app,
      id: map['id'] as String,
      user: AppUser.fromMap(map['user'] as Map<String, dynamic>),
      description: map['description'] as String,
      appVersion: map['app_version'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
      isResolved: map['is_resolved'] as bool? ?? false,
      resolutionNotes: map['resolution_notes'] != null
          ? map['resolution_notes'] as String
          : null,
      screenshotUrl: map['screenshot_url'] != null
          ? map['screenshot_url'] as String
          : null,
    );
  }

  @override
  String toString() {
    return 'BugReport(id: $id, user: $user, description: $description, appVersion: $appVersion, app: $app, createdAt: $createdAt, updatedAt: $updatedAt, isResolved: $isResolved, resolutionNotes: $resolutionNotes, screenshotUrl: $screenshotUrl)';
  }

  @override
  bool operator ==(covariant BugReport other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.description == description &&
        other.appVersion == appVersion &&
        other.app == app &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isResolved == isResolved &&
        other.resolutionNotes == resolutionNotes &&
        other.screenshotUrl == screenshotUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        description.hashCode ^
        appVersion.hashCode ^
        app.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isResolved.hashCode ^
        resolutionNotes.hashCode ^
        screenshotUrl.hashCode;
  }
}
