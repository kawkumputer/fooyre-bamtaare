import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ff.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ff'),
    Locale('fr'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal mensuel en pulaar'**
  String get appSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @noAccountSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? S\'inscrire'**
  String get noAccountSignUp;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caracteres'**
  String get passwordTooShort;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Creer un compte'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @phoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Telephone (optionnel)'**
  String get phoneOptional;

  /// No description provided for @phoneHelper.
  ///
  /// In fr, this message translates to:
  /// **'Utile pour le paiement Bankily / Wave'**
  String get phoneHelper;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get nameRequired;

  /// No description provided for @accountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte cree ! Verifiez votre email si demande.'**
  String get accountCreated;

  /// No description provided for @subscribeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abonnez-vous a Fooyre Ɓamtaare'**
  String get subscribeTitle;

  /// No description provided for @subscribeBody.
  ///
  /// In fr, this message translates to:
  /// **'Pour lire toutes les editions, contactez l\'editeur pour un abonnement (Bankily, Wave, virement...). Votre acces sera active des reception du paiement.'**
  String get subscribeBody;

  /// No description provided for @free.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get free;

  /// No description provided for @subscribers.
  ///
  /// In fr, this message translates to:
  /// **'Abonnes'**
  String get subscribers;

  /// No description provided for @loadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement.\nTirez vers le bas pour reessayer.'**
  String get loadError;

  /// No description provided for @noEditions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune edition disponible pour le moment.'**
  String get noEditions;

  /// No description provided for @noFreeEditions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune edition gratuite disponible.\nAbonnez-vous pour acceder au journal.'**
  String get noFreeEditions;

  /// No description provided for @downloadingEdition.
  ///
  /// In fr, this message translates to:
  /// **'Telechargement de l\'edition...'**
  String get downloadingEdition;

  /// No description provided for @pdfOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir cette edition.\nVerifiez votre connexion ou votre abonnement.'**
  String get pdfOpenError;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Reessayer'**
  String get retry;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get myProfile;

  /// No description provided for @noPhone.
  ///
  /// In fr, this message translates to:
  /// **'Pas de telephone'**
  String get noPhone;

  /// No description provided for @noName.
  ///
  /// In fr, this message translates to:
  /// **'(sans nom)'**
  String get noName;

  /// No description provided for @subActive.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement actif'**
  String get subActive;

  /// No description provided for @subInactive.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'abonnement actif'**
  String get subInactive;

  /// No description provided for @subExpiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date} ({days} jours restants)'**
  String subExpiresOn(String date, int days);

  /// No description provided for @subscribeContact.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous abonner, contactez l\'editeur du journal (Bankily, Wave, virement...). Votre acces sera active des reception du paiement.'**
  String get subscribeContact;

  /// No description provided for @adminAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte administrateur'**
  String get adminAccount;

  /// No description provided for @adminUnlimited.
  ///
  /// In fr, this message translates to:
  /// **'Acces illimite a toutes les editions'**
  String get adminUnlimited;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se deconnecter'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @subscriptionOf.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement de {name}'**
  String subscriptionOf(String name);

  /// No description provided for @setEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Definir la date de fin...'**
  String get setEndDate;

  /// No description provided for @editEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la date de fin...'**
  String get editEndDate;

  /// No description provided for @deactivateAccess.
  ///
  /// In fr, this message translates to:
  /// **'Desactiver l\'acces'**
  String get deactivateAccess;

  /// No description provided for @accessDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Acces desactive.'**
  String get accessDeactivated;

  /// No description provided for @endDateHelp.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin de l\'abonnement'**
  String get endDateHelp;

  /// No description provided for @subUntil.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement actif jusqu\'au {date}.'**
  String subUntil(String date);

  /// No description provided for @noSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'abonnement'**
  String get noSubscription;

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire {date}'**
  String expiresOn(String date);

  /// No description provided for @expiresSoon.
  ///
  /// In fr, this message translates to:
  /// **'bientot !'**
  String get expiresSoon;

  /// No description provided for @publishEdition.
  ///
  /// In fr, this message translates to:
  /// **'Publier une edition'**
  String get publishEdition;

  /// No description provided for @editionNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numero de l\'edition'**
  String get editionNumber;

  /// No description provided for @editionNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : 262'**
  String get editionNumberHint;

  /// No description provided for @invalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numero invalide'**
  String get invalidNumber;

  /// No description provided for @title.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Fooyre Ɓamtaare 262'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Titre requis'**
  String get titleRequired;

  /// No description provided for @freeEdition.
  ///
  /// In fr, this message translates to:
  /// **'Edition gratuite'**
  String get freeEdition;

  /// No description provided for @freeEditionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accessible a tous, meme sans abonnement'**
  String get freeEditionSubtitle;

  /// No description provided for @choosePdf.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier PDF'**
  String get choosePdf;

  /// No description provided for @publish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publish;

  /// No description provided for @publishing.
  ///
  /// In fr, this message translates to:
  /// **'Publication...'**
  String get publishing;

  /// No description provided for @chooseFileFirst.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord un fichier PDF.'**
  String get chooseFileFirst;

  /// No description provided for @editionPublished.
  ///
  /// In fr, this message translates to:
  /// **'Edition publiee !'**
  String get editionPublished;

  /// No description provided for @publishedEditions.
  ///
  /// In fr, this message translates to:
  /// **'Editions publiees'**
  String get publishedEditions;

  /// No description provided for @deleteEditionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette edition ?'**
  String get deleteEditionTitle;

  /// No description provided for @deleteEditionBody.
  ///
  /// In fr, this message translates to:
  /// **'N°{numero} — {titre}\n\nLe fichier PDF et l\'edition seront supprimes definitivement.'**
  String deleteEditionBody(int numero, String titre);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @editionDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Edition supprimee.'**
  String get editionDeleted;

  /// No description provided for @noEditionsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune edition publiee pour le moment.'**
  String get noEditionsYet;

  /// No description provided for @loadErrorEditions.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des editions.'**
  String get loadErrorEditions;

  /// No description provided for @navEditions.
  ///
  /// In fr, this message translates to:
  /// **'Editions'**
  String get navEditions;

  /// No description provided for @navSubscribers.
  ///
  /// In fr, this message translates to:
  /// **'Abonnes'**
  String get navSubscribers;

  /// No description provided for @navPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get navPublish;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @errorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {message}'**
  String errorWithMessage(String message);
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
      <String>['ff', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ff':
      return AppLocalizationsFf();
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
