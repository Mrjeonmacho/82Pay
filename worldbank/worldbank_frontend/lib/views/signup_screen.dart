import 'package:flutter/material.dart';
import 'package:worldbank_app/core/widgets/pali_input_field.dart';
import 'package:worldbank_app/views/login_screen.dart';
import '../services/user_service.dart';
import '../core/constant/bank_constant.dart';
import 'package:easy_localization/easy_localization.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  final UserService _userService = UserService();

  // 1단계 컨트롤러
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  bool _isEmailChecked = false; // 중복확인 완료 여부

  // 2단계 컨트롤러
  final _nameController = TextEditingController(); // 이름 추가
  String? _selectedCountryKey;
  Map<String, dynamic>? _selectedBank;
  final _accountPwController = TextEditingController();
  final FocusNode _accountPwFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 이름이 입력되는 것을 감지하여 국가 선택창을 띄우기 위한 리스너
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _accountPwController.dispose();
    _accountPwFocusNode.dispose();
    super.dispose();
  }

  void _showSelectionModal({
    required String title,
    required List<Widget> children,
  }) {
    FocusScope.of(context).unfocus(); // 포커스 해제하여 상태 유지 방지

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(child: Column(children: children)),
            ),
          ],
        ),
      ),
    );
  }

  // 이메일 중복 확인 로직
  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    // 1. 형식 검사
    bool isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    if (!isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.error_invalid_email'.tr())),
      );
      return;
    }

    // 2. 형식이 맞을 때만 중복 체크 실행
    final isAvailable = await _userService.checkEmailDuplicate(email);
    if (isAvailable) {
      setState(() => _isEmailChecked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.success_email_available'.tr())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.error_email_taken'.tr())),
      );
    }
  }

  // 1단계 전용 검증 함수
  void _validateStep1() {
    final email = _emailController.text.trim();
    final pw = _pwController.text;

    // 1. 이메일 중복확인 여부 체크
    if (!_isEmailChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.error_need_verification'.tr())),
      );
      return;
    }

    // 2. 비밀번호 유효성 체크 (영문, 숫자, 특수문자 조합 8자 이상)
    final pwRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
    );
    if (!pwRegExp.hasMatch(pw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('signup.messages.error_invalid_password_format'.tr()),
        ),
      );
      return;
    }

    // 모든 조건 만족 시 2단계로 이동
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 최종 회원가입 제출
  Future<void> _submitSignup() async {
    const Map<String, String> countryCodeMap = {
      'CN': 'CH', // 중국: 프론트(CN) -> 백엔드(CH)
      'US': 'US', // 미국: 동일
      'KR': 'KR', // 한국: 동일
      'JP': 'JP',
    };

    final accountPw = _accountPwController.text;

    String finalCountryCode =
        countryCodeMap[_selectedCountryKey] ?? _selectedCountryKey ?? "";

    // 2. 계좌 비밀번호 유효성 (숫자 4자리)
    if (accountPw.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(accountPw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.error_invalid_bank_pw'.tr())),
      );
      return;
    }

    // 3. 필수 선택 사항 확인 (국가, 은행)
    if (_selectedCountryKey == null || _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.messages.error_select_required'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print(_selectedBank!['bankCode'].toString());
      print(_selectedBank!['name'].toString());
      print(finalCountryCode);
      print(_emailController.text.trim());
      print(_pwController.text.trim());
      print(_nameController.text.trim());
      print(_accountPwController.text.trim());
      // UserService 호출
      final success = await _userService.signUp(
        _emailController.text.trim(),
        _pwController.text.trim(),
        finalCountryCode, // 국가 코드 (예: 'US')
        _nameController.text.trim(),
        _selectedBank!['bankCode'].toString(), // 은행 코드 (예: 'CHASUS33')
        _selectedBank!['name'].toString(), // 은행 이름 (예: 'JPMorgan Chase')
        _accountPwController.text.trim(), // 계좌 비밀번호
      );

      if (success) {
        // 성공 시 알림 후 로그인 화면으로 이동
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('signup.messages.success_signup'.tr())),
        );
        // 이동 (기존 페이지 스택을 모두 비우고 로그인으로 이동하는 것이 좋습니다)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ), // LoginScreen 호출
          (route) => false, // 이전 스택(회원가입 페이지 등)을 모두 제거
        );
      } else {
        // 실패 시 에러 메시지
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('signup.messages.error_signup_failed'.tr())),
        );
      }
    } catch (e) {
      print("회원가입 과정 에러: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 금지 (버튼으로만 이동)
        children: [_buildStep1(), _buildStep2()],
      ),
    );
  }

  // --- 1단계: 계정 정보 ---
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "signup.labels.title_account_info".tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: PaliInputField(
                          hintText: "signup.labels.email_address".tr(),
                          controller: _emailController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSmallButton(
                        _checkEmail,
                        _isEmailChecked
                            ? "signup.buttons.check_done".tr()
                            : "signup.buttons.check_duplicate".tr(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PaliInputField(
                    hintText: "signup.labels.password".tr(),
                    controller: _pwController,
                    isPassword: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildNextButton(() {
              _validateStep1();
            }, "signup.buttons.next".tr()),
          ),
        ],
      ),
    );
  }

  // --- 2단계: 상세 정보 (포커스 개선 버전) ---
  Widget _buildStep2() {
    final countryData = BankConstants.countryData;
    Map<String, dynamic>? selectedCountryData = _selectedCountryKey != null
        ? BankConstants.countryData[_selectedCountryKey!]
        : null;

    final List<dynamic> bankList = selectedCountryData != null
        ? selectedCountryData['banks'] as List<dynamic>
        : [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "signup.labels.title_detail_info".tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 1. 이름 입력: 입력 완료 시 키보드를 닫도록 유도
                  PaliInputField(
                    hintText: "signup.labels.name".tr(),
                    controller: _nameController,
                    onChanged: (val) => setState(() {}),
                    maxLength: 50,
                  ),

                  // 국가 선택 버튼
                  if (_nameController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSelectField(
                      label: "signup.labels.select_country".tr(),
                      value: selectedCountryData?['countryName'],
                      onTap: () {
                        // 국가 선택을 누르는 순간 이름 칸의 포커스를 해제합니다.
                        FocusScope.of(context).unfocus();
                        _showSelectionModal(
                          title: "signup.labels.hint_country".tr(),
                          children: countryData.entries
                              .map(
                                (e) => ListTile(
                                  title: Text(e.value['countryName']),
                                  onTap: () {
                                    setState(() {
                                      _selectedCountryKey = e.key;
                                      _selectedBank = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],

                  // 은행 선택 버튼
                  if (_selectedCountryKey != null) ...[
                    const SizedBox(height: 16),
                    _buildSelectField(
                      label: "signup.labels.select_bank".tr(),
                      value: _selectedBank?['name'],
                      onTap: () {
                        // 은행 선택 시에도 혹시 남아있을 포커스를 해제합니다.
                        FocusScope.of(context).unfocus();
                        _showSelectionModal(
                          title: "signup.labels.hint_bank".tr(),
                          children: bankList.map<Widget>((bank) {
                            final b = Map<String, dynamic>.from(bank as Map);
                            return ListTile(
                              leading: Image.asset(
                                b['logo'] as String,
                                width: 30,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.account_balance),
                              ),
                              title: Text(b['name'] as String),
                              onTap: () {
                                setState(() {
                                  _selectedBank = b;
                                });
                                Navigator.pop(context);

                                // ✅ 핵심: 은행 선택 모달이 닫힌 후 계좌 비밀번호로 포커스 강제 이동
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (mounted) {
                                      _accountPwFocusNode.requestFocus();
                                    }
                                  },
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],

                  // 4. 계좌 비밀번호 (은행 선택 시 노출)
                  if (_selectedBank != null) ...[
                    const SizedBox(height: 20),
                    PaliInputField(
                      hintText: "signup.labels.bank_password".tr(),
                      controller: _accountPwController,
                      focusNode: _accountPwFocusNode, // 미리 선언해두신 노드 연결
                      isPassword: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNextButton(
                    _submitSignup,
                    "signup.buttons.complete_signup".tr(),
                  ),
          ),
        ],
      ),
    );
  }

  // --- 공통 레이아웃 가이드 ---

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSelectField({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: TextStyle(
                fontSize: 16,
                color: value != null ? Colors.black : Colors.grey[600],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton(VoidCallback onPressed, String label) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEmailChecked
            ? Colors.grey
            : const Color(0xFFE2D696),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2D696),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
