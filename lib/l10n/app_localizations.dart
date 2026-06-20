import 'package:flutter/material.dart';

/// Core UI strings (en / te / hi) — Android `values`, `values-te`, `values-hi`.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('te'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String _t(Map<String, String> values) =>
      values[locale.languageCode] ?? values['en']!;

  String get navHome => _t({
    'en': 'Home',
    'te': 'హోమ్',
    'hi': 'होम',
  });

  String get navCategory => _t({
    'en': 'Category',
    'te': 'వర్గం',
    'hi': 'श्रेणी',
  });

  String get navOrders => _t({
    'en': 'Orders',
    'te': 'ఆర్డర్లు',
    'hi': 'ऑर्डर',
  });

  String get navAccount => _t({
    'en': 'Account',
    'te': 'ఖాతా',
    'hi': 'खाता',
  });

  String get loginOrSignup => _t({
    'en': 'Login or Signup',
    'te': 'లాగిన్ లేదా సైన్ అప్',
    'hi': 'लॉगिन या साइन अप',
  });

  String get enterMobileToContinue => _t({
    'en': 'Enter your mobile number to continue',
    'te': 'కొనసాగడానికి మీ మొబైల్ నంబర్ నమోదు చేయండి',
    'hi': 'जारी रखने के लिए अपना मोबाइल नंबर दर्ज करें',
  });

  String get enterMobileNumber => _t({
    'en': 'Enter mobile number',
    'te': 'మొబైల్ నంబర్ నమోదు చేయండి',
    'hi': 'मोबाइल नंबर दर्ज करें',
  });

  String get continueButton => _t({
    'en': 'Continue',
    'te': 'కొనసాగించు',
    'hi': 'जारी रखें',
  });

  String get selectCountry => _t({
    'en': 'Select your country',
    'te': 'మీ దేశాన్ని ఎంచుకోండి',
    'hi': 'अपना देश चुनें',
  });

  String get language => _t({
    'en': 'Language',
    'te': 'భాష',
    'hi': 'भाषा',
  });

  String get languageSaved => _t({
    'en': 'Language saved',
    'te': 'భాష సేవ్ చేయబడింది',
    'hi': 'भाषा सहेजी गई',
  });

  String get couldNotSaveLanguage => _t({
    'en': 'Could not save language',
    'te': 'భాషను సేవ్ చేయలేకపోయాం',
    'hi': 'भाषा सहेज नहीं सकी',
  });

  String get addressBook => _t({
    'en': 'Address Book',
    'te': 'చిరునామా పుస్తకం',
    'hi': 'पता पुस्तिका',
  });

  String get allOrders => _t({
    'en': 'All Orders',
    'te': 'అన్ని ఆర్డర్లు',
    'hi': 'सभी ऑर्डर',
  });

  String get favourites => _t({
    'en': 'Favourites',
    'te': 'ఇష్టమైనవి',
    'hi': 'पसंदीदा',
  });

  String get referEarn => _t({
    'en': 'Refer & Earn',
    'te': 'రెఫర్ & సంపాదించండి',
    'hi': 'रेफर और कमाएं',
  });

  String get help => _t({
    'en': 'Help',
    'te': 'సహాయం',
    'hi': 'मदद',
  });

  String get helpFaq => _t({
    'en': 'Help & FAQ',
    'te': 'సహాయం & తరచుగా అడిగే ప్రశ్నలు',
    'hi': 'मदद और FAQ',
  });

  String get logout => _t({
    'en': 'LOGOUT',
    'te': 'లాగ్అవుట్',
    'hi': 'लॉगआउट',
  });

  String get login => _t({
    'en': 'LOGIN',
    'te': 'లాగిన్',
    'hi': 'लॉगिन',
  });

  String get walletBalance => _t({
    'en': 'Wallet balance',
    'te': 'వాలెట్ బ్యాలెన్స్',
    'hi': 'वॉलेट बैलेंस',
  });

  String get navWallet => _t({
    'en': 'Wallet',
    'te': 'వాలెట్',
    'hi': 'वॉलेट',
  });

  String get currentWalletBalance => _t({
    'en': 'Current Wallet Balance',
    'te': 'ప్రస్తుత వాలెట్ బ్యాలెన్స్',
    'hi': 'वर्तमान वॉलेट बैलेंस',
  });

  String get addMoney => _t({
    'en': 'Add money',
    'te': 'డబ్బు జోడించండి',
    'hi': 'पैसे जोड़ें',
  });

  String get enterAmount => _t({
    'en': 'Enter amount',
    'te': 'మొత్తం నమోదు చేయండి',
    'hi': 'राशि दर्ज करें',
  });

  String get walletInvalidAmount => _t({
    'en': 'Please enter a valid amount',
    'te': 'దయచేసి సరైన మొత్తాన్ని నమోదు చేయండి',
    'hi': 'कृपया वैध राशि दर्ज करें',
  });

  String get walletPaymentFailed => _t({
    'en': 'Payment failed. Please try again.',
    'te': 'చెల్లింపు విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.',
    'hi': 'भुगतान विफल। कृपया पुनः प्रयास करें।',
  });

  String get loading => _t({
    'en': 'Loading...',
    'te': 'లోడ్ అవుతోంది...',
    'hi': 'लोड हो रहा है...',
  });

  String get walletTransactions => _t({
    'en': 'Transaction history',
    'te': 'లావాదేవీ చరిత్ర',
    'hi': 'लेन-देन इतिहास',
  });

  String get noWalletTransactions => _t({
    'en': 'No wallet transactions yet',
    'te': 'వాలెట్ లావాదేవీలు లేవు',
    'hi': 'अभी कोई वॉलेट लेन-देन नहीं',
  });

  String get transactionId => _t({
    'en': 'Transaction ID',
    'te': 'లావాదేవీ ID',
    'hi': 'लेन-देन ID',
  });

  String get credit => _t({
    'en': 'Credit',
    'te': 'క్రెడిట్',
    'hi': 'क्रेडिट',
  });

  String get debit => _t({
    'en': 'Debit',
    'te': 'డెబిట్',
    'hi': 'डेबिट',
  });

  String get menuTab => _t({
    'en': 'Menu',
    'te': 'మెనూ',
    'hi': 'मेनू',
  });

  String get aboutTab => _t({
    'en': 'About',
    'te': 'గురించి',
    'hi': 'के बारे में',
  });

  String get reviewsTab => _t({
    'en': 'Reviews',
    'te': 'సమీక్షలు',
    'hi': 'समीक्षाएं',
  });

  String get cancelOrder => _t({
    'en': 'Cancel order',
    'te': 'ఆర్డర్ రద్దు',
    'hi': 'ऑर्डर रद्द करें',
  });

  String get retry => _t({
    'en': 'Retry',
    'te': 'మళ్లీ ప్రయత్నించండి',
    'hi': 'पुनः प्रयास करें',
  });
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'te', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
