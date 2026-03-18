// 한 번에 모든 위젯을 가져올 수 있도록 위젯들을 EXPORT 하는 BARREL

export 'pali_button.dart';
export 'pali_card.dart';
export 'pali_input_field.dart';
export 'pali_nav_bars.dart';
export 'pali_scanner_frame.dart';
export 'pali_transaction_list.dart';
export 'pali_keypad.dart';

// ============================================
// 사용 방법
// ============================================

// import 'package:flutter/material.dart';
// import '../../../core/widgets/widgets.dart'; // 공통 위젯 한 번에 불러오기

// // ... 중략 ...
// Column(
//   children: [
//     PaliInputField(hintText: '이메일을 입력해주세요'),
//     const SizedBox(height: 16),
//     PaliButton(
//       text: '로그인',
//       onPressed: () => print('로그인 시도'),
//     ),
//   ],
// )
