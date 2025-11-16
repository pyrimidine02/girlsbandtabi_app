import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('1. 총칙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('걸즈밴드타비(이하 "서비스")는 이용자의 개인정보 보호를 중요시하며, 관련 법령을 준수합니다.'),
          SizedBox(height: 16),
          Text('2. 수집하는 개인정보 항목 및 방법', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('회원가입, 서비스 이용 과정에서 이메일, 닉네임 등 필요한 최소한의 개인정보를 수집할 수 있습니다.'),
          SizedBox(height: 16),
          Text('3. 개인정보의 수집 및 이용 목적', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('서비스 제공, 회원관리, 공지 및 민원처리, 보안 및 부정이용 방지 등의 목적을 위해 수집된 정보를 이용합니다.'),
          SizedBox(height: 16),
          Text('4. 보유 및 이용기간', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('관련 법령에 따른 보존기간 또는 회원 탈퇴 시까지 보유·이용합니다.'),
          SizedBox(height: 16),
          Text('5. 제3자 제공 및 처리위탁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('법령에 근거하거나 이용자의 사전 동의를 받은 경우에 한해 제3자 제공 또는 위탁을 진행합니다.'),
          SizedBox(height: 16),
          Text('6. 이용자 권리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('이용자는 개인정보 열람, 정정, 삭제, 처리정지 등을 요청할 수 있습니다.'),
          SizedBox(height: 16),
          Text('7. 보안조치', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('서비스는 기술적/관리적 보안조치를 통해 개인정보를 보호합니다.'),
          SizedBox(height: 16),
          Text('부칙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('본 개인정보 처리방침은 게시한 날로부터 시행합니다.'),
        ],
      ),
    );
  }
}

