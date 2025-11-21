/// EN: Simple application configuration
/// KO: 간단한 애플리케이션 설정
class AppConfig {
  /// EN: API base URL - Change this for deployment
  /// KO: API 기본 URL - 배포시 이것을 변경하세요
  /// 
  /// 🔧 FOR DEPLOYMENT / 배포용:
  /// - Development: 'http://10.0.2.2:8080' (Android Emulator)
  /// - Physical Device: 'http://192.168.50.141:8080' (Your machine IP)  
  /// - Production: 'https://your-production-server.com'
  static const String baseUrl = 'http://10.0.2.2:8080';
}