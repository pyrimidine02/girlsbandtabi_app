class ProjectRole {
  ProjectRole({
    required this.userId,
    required this.role,
    this.assignedAt,
    this.assignedBy,
    this.status,
  });

  final String userId;
  final String role;
  final DateTime? assignedAt;
  final String? assignedBy;
  final String? status;

  factory ProjectRole.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return ProjectRole(
      userId: map['userId']?.toString() ?? map['id']?.toString() ?? '',
      role: map['role']?.toString() ?? 'UNKNOWN',
      assignedAt: parseDate(
        map['assignedAt'] ?? map['updatedAt'] ?? map['createdAt'],
      ),
      assignedBy: map['assignedBy']?.toString() ?? map['issuer']?.toString(),
      status: map['status']?.toString(),
    );
  }
}
