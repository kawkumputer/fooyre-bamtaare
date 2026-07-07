// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Fulah (`ff`).
class AppLocalizationsFf extends AppLocalizations {
  AppLocalizationsFf([String locale = 'ff']) : super(locale);

  @override
  String get appSubtitle => 'Jaaynde lewruure he pulaar';

  @override
  String get email => 'Iimeel';

  @override
  String get password => 'Finnde';

  @override
  String get login => 'Seŋaade';

  @override
  String get noAccountSignUp => 'Alaa konte? Winndito';

  @override
  String get invalidEmail => 'iimeel moƴƴaani';

  @override
  String get passwordTooShort => 'Ko famɗi fof alkule 6';

  @override
  String get createAccount => 'Sosde konte';

  @override
  String get fullName => 'Innde timmunde';

  @override
  String get phoneOptional => 'Telefon (waɗɗaaki)';

  @override
  String get phoneHelper => 'Ina soklaa he njoɓdi Bankily / Wave';

  @override
  String get signUp => 'Winnditaade';

  @override
  String get nameRequired => 'Innde ina waɗɗii';

  @override
  String get accountCreated => 'Konte sosaama! A waawi naatde jooni.';

  @override
  String get subscribeTitle => 'Lulno e Fooyre Ɓamtaare';

  @override
  String get subscribeBody =>
      'Ngam mbaawaa tarde tonngooɗe ɗee fof, jokkondir e caaktoowo oo mbele lulno-ɗaa (Bankily, Wave, rewrude e booñ...). Damal maa udditano ma caggal nde njoɓɗaa.';

  @override
  String get free => 'Alaa njoɓdi';

  @override
  String get subscribers => 'Lulniiɓe';

  @override
  String get loadError => 'Juumre loowgol.\nFooɗir les ngam enndude kadi.';

  @override
  String get noEditions => 'Alaa tonngoode woodi e oo sahaa.';

  @override
  String get noFreeEditions =>
      'Alaa tonngoode nde yoɓetaake woodi.\nLulno heɓde jaaynde ndee.';

  @override
  String get downloadingEdition => 'Gawtagol tonngoode ndee...';

  @override
  String get pdfOpenError =>
      'Ndee tonngoode uddittaako.\nYuurnito seŋorde maa walla lulnagol maa.';

  @override
  String get retry => 'Enndit';

  @override
  String get myProfile => 'Heftinirde am';

  @override
  String get noPhone => 'Alaa telefon';

  @override
  String get noName => '(alaa innde)';

  @override
  String get subActive => 'Aɗa lulnii';

  @override
  String get subInactive => 'A lulnaaki';

  @override
  String subExpiresOn(String date, int days) {
    return 'Gasata ko ñalnde $date (balɗe $days keddii)';
  }

  @override
  String get subscribeContact =>
      'Ngam lulnaade, jokkondir e caakto jaaynde ndee (Bankily, Wave, booñ...). Damal maa udditano ma so a yoɓii.';

  @override
  String get adminAccount => 'Konte jiiloowo';

  @override
  String get adminUnlimited => 'Keɓgol tonngooɗe ɗee fof';

  @override
  String get signOut => 'Seŋtaade';

  @override
  String get language => 'Ɗemngal';

  @override
  String get deleteMyAccount => 'Momtude konte am';

  @override
  String get deleteMyAccountConfirmTitle => 'Momtude konte maa haa poomaa ?';

  @override
  String get deleteMyAccountConfirmBody =>
      'Ngol golle waawaa firtireede. Heftinirde maa, lulnagol maa e kala keɓe maa momtete haa poomaa.';

  @override
  String get myAccountDeleted => 'Konte maa momtaama.';

  @override
  String get confirmUserEmail => 'Teeŋtin iimeel';

  @override
  String get userEmailConfirmed => 'Iimeel teeŋtinaama.';

  @override
  String get emailNotConfirmed => 'Iimeel teeŋtinaaka';

  @override
  String get deleteUserAccount => 'Momtude konte';

  @override
  String get deleteUserConfirmTitle => 'Momtude ndee konte ?';

  @override
  String deleteUserConfirmBody(String name) {
    return 'Konte $name momtete haa poomaa, e kala keɓe mum. Ngol golle waawaa firtireede.';
  }

  @override
  String get userAccountDeleted => 'Konte momtaama.';

  @override
  String get editProfile => 'Waylu heftinirde';

  @override
  String get save => 'Danndu';

  @override
  String get profileUpdated => 'Heftinirde waylaama.';

  @override
  String get emailNotEditable => 'Iimeel waawaa wayleede.';

  @override
  String get changePassword => 'Waylu finnde';

  @override
  String get newPassword => 'Finnde hesere';

  @override
  String get confirmPassword => 'Teeŋtin finnde ndee';

  @override
  String get passwordsDontMatch => 'Finndeeji ɗii nanndaani';

  @override
  String get passwordUpdated => 'Finnde waylaama.';

  @override
  String get subscribeForFull => 'Lulno ngam tarde tonngoode timmunde';

  @override
  String get editionComplete => 'Tonngoode timmunde';

  @override
  String get chooseFullPdf => 'PDF timmuɗo (lulniiɓe)';

  @override
  String get chooseCoverImage => 'Natal ngal (yeeso tonngoode)';

  @override
  String get chooseFromGallery => 'Suɓaade e nataleeji';

  @override
  String get chooseFromFiles => 'Suɓaade e fiilde';

  @override
  String get coverLabel => 'Natal';

  @override
  String get coverAndPdfRequired =>
      'Natal ngal e PDF timmuɗo ɗiɗi fof ina waɗɗii.';

  @override
  String get publicationDate => 'Ñalnde yaltugol';

  @override
  String publishedOn(String date) {
    return 'Yaltii ñalnde $date';
  }

  @override
  String get subscribeDialogTitle => 'Tonngoode timmunde';

  @override
  String get subscribeDialogBody =>
      'Ngam tarde tonngoode timmunde, aɗa foti lulnaade. Jokkondir e caakto jaaynde ndee ngam heɓde damal (Bankily, Wave, booñ...).';

  @override
  String get close => 'Uddu';

  @override
  String get editionUnavailable => 'Tonngoode ndee alaa e oo sahaa.';

  @override
  String subscriptionOf(String name) {
    return 'Lulnagol $name';
  }

  @override
  String get setEndDate => 'Toɗɗo lajal timmugol...';

  @override
  String get editEndDate => 'Waylu lajal timmugol...';

  @override
  String get deactivateAccess => 'Sok damal';

  @override
  String get accessDeactivated => 'Damal sokaama';

  @override
  String get endDateHelp => 'Lajal gasgol lulnde';

  @override
  String subUntil(String date) {
    return 'Aɗa lulnii haa $date.';
  }

  @override
  String get noSubscription => 'Lulnaaki';

  @override
  String expiresOn(String date) {
    return 'Gasata $date';
  }

  @override
  String get expiresSoon => 'ɓooyata !';

  @override
  String get publishEdition => 'Yollu tonngoode';

  @override
  String get editionNumber => 'Limoore tonngoode';

  @override
  String get editionNumberHint => 'yeru : 262';

  @override
  String get invalidNumber => 'Tonngoode woodaani';

  @override
  String get title => 'Tiitoonde';

  @override
  String get titleHint => 'yeru : Tonngoode 262';

  @override
  String get titleRequired => 'Tiitoonde ina waɗɗii';

  @override
  String get freeEdition => 'Tiitoonde yoɓetaake';

  @override
  String get freeEditionSubtitle => 'Yimɓe fof ine keɓa nde, hay so lulnaaki';

  @override
  String get choosePdf => 'Suɓaade fiilde PDF';

  @override
  String get publish => 'Saaktude';

  @override
  String get publishing => 'Caaktugol...';

  @override
  String get chooseFileFirst => 'Suɓo tawo fiilde PDF.';

  @override
  String get editionPublished => 'Tonngoode saaktaama!';

  @override
  String get publishedEditions => 'Tonngooɗe caaktaaɗe';

  @override
  String get deleteEditionTitle => 'Momtude ndee tonngoode ?';

  @override
  String deleteEditionBody(int numero, String titre) {
    return 'Tŋ $numero — $titre\n\nFiilde PDF ndee e tonngoode ndee momtete haa bada.';
  }

  @override
  String get cancel => 'Haaytude';

  @override
  String get delete => 'Momtude';

  @override
  String get editionDeleted => 'Tonngoode momtaama.';

  @override
  String get noEditionsYet => 'Alaa tonngoode saaktaa e o sahaa.';

  @override
  String get loadErrorEditions => 'Juumre loowgol tonngooɗe.';

  @override
  String get searchEditionHint => 'Yiylo limoore tonngoode';

  @override
  String get searchUserHint => 'Yiylo innde walla telefon';

  @override
  String get noSearchResult => 'Alaa ko heɓaa.';

  @override
  String get navEditions => 'Tonngooɗe';

  @override
  String get navSubscribers => 'Lulniiɓe';

  @override
  String get navPublish => 'Saaktude';

  @override
  String get navProfile => 'Heftinirde';

  @override
  String errorWithMessage(String message) {
    return 'Juumre : $message';
  }
}
