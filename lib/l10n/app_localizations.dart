import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Parking Alert'**
  String get appTitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark themes'**
  String get darkModeSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current: English'**
  String get languageSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage alert sounds'**
  String get notificationsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle data'**
  String get privacyPolicySubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get helpSupportSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @urbanRoadGuard.
  ///
  /// In en, this message translates to:
  /// **'Urban Road Guard 🛡️'**
  String get urbanRoadGuard;

  /// No description provided for @notifyDrivers.
  ///
  /// In en, this message translates to:
  /// **'Notify drivers instantly and keep the route clear.'**
  String get notifyDrivers;

  /// No description provided for @newAlert.
  ///
  /// In en, this message translates to:
  /// **'New Alert ⚠️'**
  String get newAlert;

  /// No description provided for @plateNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Plate Number (ex: 123 TUN 456)'**
  String get plateNumberHint;

  /// No description provided for @issueHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s the issue?'**
  String get issueHint;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Immediate Alert'**
  String get sendAlert;

  /// No description provided for @secureAnonymousUrban.
  ///
  /// In en, this message translates to:
  /// **'Secure • Anonymous • Urban'**
  String get secureAnonymousUrban;

  /// No description provided for @errorPlateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a plate number 🚗'**
  String get errorPlateEmpty;

  /// No description provided for @errorMessageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message ✉️'**
  String get errorMessageEmpty;

  /// No description provided for @errorPlateNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This plate is not registered ❌'**
  String get errorPlateNotRegistered;

  /// No description provided for @successAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Alert sent successfully ✅'**
  String get successAlertSent;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @introSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quickly notify drivers\nblocking you'**
  String get introSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @freeToUse.
  ///
  /// In en, this message translates to:
  /// **'Free to use • No account required'**
  String get freeToUse;

  /// No description provided for @featureInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get featureInstant;

  /// No description provided for @featureAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get featureAnonymous;

  /// No description provided for @featureCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get featureCommunity;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @matriculeHint.
  ///
  /// In en, this message translates to:
  /// **'Matricule (ex: 123 TUN 456)'**
  String get matriculeHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneHint;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Login'**
  String get alreadyRegistered;

  /// No description provided for @registerBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerBtn;

  /// No description provided for @successUserRegistered.
  ///
  /// In en, this message translates to:
  /// **'User registered successfully'**
  String get successUserRegistered;

  /// No description provided for @registerHeader.
  ///
  /// In en, this message translates to:
  /// **'Register your\ncar'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this info to identify you as\nthe car owner when alerts are sent.'**
  String get registerSubtitle;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlateLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @errorLicensePlateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your license plate'**
  String get errorLicensePlateEmpty;

  /// No description provided for @errorPhoneNumberEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get errorPhoneNumberEmpty;

  /// No description provided for @errorPhoneNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number seems too short'**
  String get errorPhoneNumberShort;

  /// No description provided for @infoLocallyStored.
  ///
  /// In en, this message translates to:
  /// **'Your info is stored locally only.'**
  String get infoLocallyStored;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent Alerts'**
  String get recentAlerts;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear! No alerts.'**
  String get allClear;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From: '**
  String get fromLabel;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @errorAllFields.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get errorAllFields;

  /// No description provided for @successProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully! ✅'**
  String get successProfileUpdated;

  /// No description provided for @cancelEditing.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get cancelEditing;

  /// No description provided for @messageHistory.
  ///
  /// In en, this message translates to:
  /// **'Message History'**
  String get messageHistory;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noReceivedMessages.
  ///
  /// In en, this message translates to:
  /// **'No received messages'**
  String get noReceivedMessages;

  /// No description provided for @noSentMessages.
  ///
  /// In en, this message translates to:
  /// **'No sent messages'**
  String get noSentMessages;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To: '**
  String get toLabel;

  /// No description provided for @readStatus.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get readStatus;

  /// No description provided for @sentStatus.
  ///
  /// In en, this message translates to:
  /// **'SENT'**
  String get sentStatus;

  /// No description provided for @newStatus.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
