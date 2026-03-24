// 정적으로 관리하는 각 국 은행 db
class BankConstants {
  static const Map<String, Map<String, dynamic>> countryData = {
    'US': {
      'defaultMoneyCode': 'USD', // 이 국가의 기본 통화
      'countryName': 'United States',
      'banks': [
        {
          'name': 'JPMorgan Chase',
          'bankCode': 'CHASUS33',
          'logo': 'assets/images/banks/us/us_jpm.png',
        },
        {
          'name': 'Bank of America',
          'bankCode': 'BOFAUS3N',
          'logo': 'assets/images/banks/us/us_bofa.png',
        },
        {
          'name': 'Wells Fargo',
          'bankCode': 'WFBIUS6S',
          'logo': 'assets/images/banks/us/us_wf.png',
        },
        {
          'name': 'Citibank',
          'bankCode': 'CITIUS33',
          'logo': 'assets/images/banks/us/us_citi.png',
        },
        {
          'name': 'U.S. Bancorp',
          'bankCode': 'USBKUS44',
          'logo': 'assets/images/banks/us/us_usb.png',
        },        
      ],
    },
    'CN': {
      'defaultMoneyCode': 'CNY', 
      'countryName': 'China',
      'banks': [
        {
          'name': 'Industrial and Commercial Bank of China',
          'bankCode': 'ICBKCNBJ',
          'logo': 'assets/images/banks/cn/cn_icbc.jpg',
        },
        {
          'name': 'China Construction Bank',
          'bankCode': 'PCBCCNBJ',
          'logo': 'assets/images/banks/cn/cn_ccb.png',
        },
        {
          'name': 'Agricultural Bank of China',
          'bankCode': 'ABOCCNBJ',
          'logo': 'assets/images/banks/cn/cn_aboc.png',
        },
        {
          'name': 'Bank of China',
          'bankCode': 'BKCHCNBJ',
          'logo': 'assets/images/banks/cn/cn_pccb.png',
        },
        {
          'name': 'Bank of Communications',
          'bankCode': 'COMMCNSH',
          'logo': 'assets/images/banks/cn/cn_boc.png',
        },        
        {
          'name': 'Postal Savings Bank of China',
          'bankCode': 'PSBCCNBJ',
          'logo': 'assets/images/banks/cn/cn_psbc.jpg',
        },        
      ],
    },
    'JP': {
      'defaultMoneyCode': 'JPY', 
      'countryName': 'Japan',
      'banks': [
        {
          'name': 'Japan Post Bank',
          'bankCode': 'JPPSJPJ1',
          'logo': 'assets/images/banks/jp/jp_jpb.png',
        },
        {
          'name': 'MUFG Bank',
          'bankCode': 'BOTKJPJT',
          'logo': 'assets/images/banks/jp/jp_mufg.png',
        },
        {
          'name': 'Sumitomo Mitsui Banking Corporation',
          'bankCode': 'SMBCJPJT',
          'logo': 'assets/images/banks/jp/jp_smbc.png',
        },
        {
          'name': 'Mizuho Bank',
          'bankCode': 'MHCBJPJT',
          'logo': 'assets/images/banks/jp/jp_mizuho.png',
        },
        {
          'name': 'Resona Bank',
          'bankCode': 'DIWAJPJT',
          'logo': 'assets/images/banks/jp/jp_resona.png',
        },             
      ],
    },
    'KR': {
      'defaultMoneyCode': 'KRW', 
      'countryName': 'South Korea',
      'banks': [
        {
          'name': 'KB국민은행',
          'bankCode': '004',
          'logo': 'assets/images/banks/kr/kr_kb.png',
        },
        {
          'name': '신한은행',
          'bankCode': '088',
          'logo': 'assets/images/banks/kr/kr_shinhan.png',
        },
        {
          'name': '우리은행',
          'bankCode': '020',
          'logo': 'assets/images/banks/kr/kr_woori.png',
        },
        {
          'name': '하나은행',
          'bankCode': '081',
          'logo': 'assets/images/banks/kr/kr_hana.png',
        },
        {
          'name': 'NH농협은행',
          'bankCode': '011',
          'logo': 'assets/images/banks/kr/kr_nh.png',
        },
        {
          'name': 'IBK기업은행',
          'bankCode': '003',
          'logo': 'assets/images/banks/kr/kr_ibk.png',
        },
        {
          'name': '카카오뱅크',
          'bankCode': '090',
          'logo': 'assets/images/banks/kr/kr_kakao.png',
        },
        {
          'name': '토스뱅크',
          'bankCode': '092',
          'logo': 'assets/images/banks/kr/kr_toss.png',
        },
        {
          'name': '케이뱅크',
          'bankCode': '089',
          'logo': 'assets/images/banks/kr/kr_kbank.png',
        },
        {
          'name': 'sc제일은행',
          'bankCode': '023',
          'logo': 'assets/images/banks/kr/kr_sc.png',
        },
      ],
    },
  };

  // 특정 국가의 통화 코드를 가져오는 헬퍼 메서드
  static String getDefaultCurrency(String countryCode) {
    return countryData[countryCode]?['defaultMoneyCode'] ?? 'USD';
  }

  // 특정 국가의 은행 리스트만 가져오는 헬퍼 메서드
  static List<Map<String, dynamic>> getBanks(String countryCode) {
    return countryData[countryCode]?['banks'] ?? [];
  }
}