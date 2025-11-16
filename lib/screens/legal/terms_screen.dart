import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('제1조(목적)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('본 약관은 걸즈밴드타비(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.'),
          SizedBox(height: 16),
          Text('제2조(정의)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('1. "이용자"란 본 약관에 따라 서비스를 이용하는 회원을 의미합니다.\n2. "콘텐츠"란 서비스상 제공되는 텍스트, 이미지, 정보 등을 의미합니다.'),
          SizedBox(height: 16),
          Text('제3조(약관의 명시와 개정)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('회사는 본 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 내에 게시합니다. 필요 시 관련 법령을 위반하지 않는 범위에서 약관을 개정할 수 있습니다.'),
          SizedBox(height: 16),
          Text('제4조(서비스의 제공 및 변경)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('회사는 서비스의 내용 및 제공 일정을 변경할 수 있으며, 서비스 운영상 또는 기술상 필요한 경우 서비스 제공을 중지할 수 있습니다.'),
          SizedBox(height: 16),
          Text('제5조(이용자의 의무)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('이용자는 관련 법령과 본 약관 및 서비스 이용안내에서 정한 사항을 준수하여야 하며, 서비스 운영을 방해하는 행위를 해서는 안 됩니다.'),
          SizedBox(height: 16),
          Text('제6조(책임의 제한)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('회사는 천재지변, 불가항력, 이용자의 귀책사유로 인한 서비스 장애에 대해 책임을 지지 않습니다.'),
          SizedBox(height: 16),
          Text('부칙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('본 약관은 게시한 날로부터 시행합니다.'),
        ],
      ),
    );
  }
}

