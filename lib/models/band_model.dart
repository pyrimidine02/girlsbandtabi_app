class BandUnit {
  final String id;
  final String code;
  final String displayName;
  final String? status;

  BandUnit({
    required this.id,
    required this.code,
    required this.displayName,
    this.status,
  });

  factory BandUnit.fromJson(Map<String, dynamic> json) => BandUnit(
        id: json['id'].toString(),
        code: json['code'] as String,
        displayName: json['displayName'] as String,
        status: json['status'] as String?,
      );
}

