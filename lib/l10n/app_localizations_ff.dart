// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Fulah (`ff`).
class AppLocalizationsFf extends AppLocalizations {
  AppLocalizationsFf([String locale = 'ff']) : super(locale);

  @override
  String get appSubtitle => 'Jaaynde lewru e pulaar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Finnde';

  @override
  String get login => 'Naatde';

  @override
  String get noAccountSignUp => 'Alaa konte? Winndito';

  @override
  String get invalidEmail => 'Email moƴƴaani';

  @override
  String get passwordTooShort => 'Ustaani 6 alkule';

  @override
  String get createAccount => 'Sosde konte';

  @override
  String get fullName => 'Innde timmunde';

  @override
  String get phoneOptional => 'Telefon (suɓngal)';

  @override
  String get phoneHelper => 'Ina nafa ngam njoɓdi Bankily / Wave';

  @override
  String get signUp => 'Winnditaade';

  @override
  String get nameRequired => 'Innde ina waɗɗii';

  @override
  String get accountCreated => 'Konte sosaama! Ƴeew email maa so ina naamnaa.';

  @override
  String get subscribeTitle => 'Winndito e Fooyre Ɓamtaare';

  @override
  String get subscribeBody =>
      'Ngam janngude tonngooɗe ɗe fof, jokkondir e cukko ngam winnditagol (Bankily, Wave, virement...). Naatirde maa udditoyte caggal njoɓdi.';

  @override
  String get free => 'Meere';

  @override
  String get subscribers => 'Winnditiiɓe';

  @override
  String get loadError => 'Juumre e loowgol.\nFooɗ les ngam eto kadi.';

  @override
  String get noEditions => 'Alaa tonngoode goodnde jooni.';

  @override
  String get noFreeEditions =>
      'Alaa tonngoode meere goodnde.\nWinndito ngam janngude jaaynde ndee.';

  @override
  String get downloadingEdition => 'Aawtude tonngoode ndee...';

  @override
  String get pdfOpenError =>
      'Udditde tonngoode ndee waawaaka.\nƳeew jokkondiral maa walla winnditagol maa.';

  @override
  String get retry => 'Eto kadi';

  @override
  String get myProfile => 'Profiil am';

  @override
  String get noPhone => 'Alaa telefon';

  @override
  String get noName => '(alaa innde)';

  @override
  String get subActive => 'Winnditagol ina yahra';

  @override
  String get subInactive => 'Alaa winnditagol';

  @override
  String subExpiresOn(String date, int days) {
    return 'Gasata $date (balɗe $days keddiiɗe)';
  }

  @override
  String get subscribeContact =>
      'Ngam winnditaade, jokkondir e cukko jaaynde ndee (Bankily, Wave, virement...). Naatirde maa udditoyte caggal njoɓdi.';

  @override
  String get adminAccount => 'Konte ardiiɗo';

  @override
  String get adminUnlimited => 'Naatgol e tonngooɗe ɗe fof, keeri alaa';

  @override
  String get signOut => 'Yaltude';

  @override
  String get language => 'Ɗemngal';

  @override
  String subscriptionOf(String name) {
    return 'Winnditagol $name';
  }

  @override
  String get setEndDate => 'Teelde ñalnde gasol...';

  @override
  String get editEndDate => 'Waylude ñalnde gasol...';

  @override
  String get deactivateAccess => 'Ittude naatgol';

  @override
  String get accessDeactivated => 'Naatgol ittaama.';

  @override
  String get endDateHelp => 'Ñalnde gasol winnditagol';

  @override
  String subUntil(String date) {
    return 'Winnditagol ina yahra haa $date.';
  }

  @override
  String get noSubscription => 'Alaa winnditagol';

  @override
  String expiresOn(String date) {
    return 'Gasata $date';
  }

  @override
  String get expiresSoon => 'ina ɓadii!';

  @override
  String get publishEdition => 'Yaltinde tonngoode';

  @override
  String get editionNumber => 'Limngal tonngoode';

  @override
  String get editionNumberHint => 'yeru : 262';

  @override
  String get invalidNumber => 'Limngal moƴƴaani';

  @override
  String get title => 'Tiitoonde';

  @override
  String get titleHint => 'yeru : Fooyre Ɓamtaare 262';

  @override
  String get titleRequired => 'Tiitoonde ina waɗɗii';

  @override
  String get freeEdition => 'Tonngoode meere';

  @override
  String get freeEditionSubtitle =>
      'Heɓotoo ko yimɓe fof, hay so alaa winnditagol';

  @override
  String get choosePdf => 'Suɓaade fiilde PDF';

  @override
  String get publish => 'Yaltinde';

  @override
  String get publishing => 'Ina yaltinee...';

  @override
  String get chooseFileFirst => 'Suɓo fiilde PDF adan.';

  @override
  String get editionPublished => 'Tonngoode yaltinaama!';

  @override
  String get publishedEditions => 'Tonngooɗe yaltinaaɗe';

  @override
  String get deleteEditionTitle => 'Momtude tonngoode ndee?';

  @override
  String deleteEditionBody(int numero, String titre) {
    return 'N°$numero — $titre\n\nFiilde PDF ndee e tonngoode ndee momtete haa poomaa.';
  }

  @override
  String get cancel => 'Haaytude';

  @override
  String get delete => 'Momtude';

  @override
  String get editionDeleted => 'Tonngoode momtaama.';

  @override
  String get noEditionsYet => 'Alaa tonngoode yaltinaande jooni.';

  @override
  String get loadErrorEditions => 'Juumre e loowgol tonngooɗe.';

  @override
  String get navEditions => 'Tonngooɗe';

  @override
  String get navSubscribers => 'Winnditiiɓe';

  @override
  String get navPublish => 'Yaltinde';

  @override
  String get navProfile => 'Profiil';

  @override
  String errorWithMessage(String message) {
    return 'Juumre : $message';
  }
}
