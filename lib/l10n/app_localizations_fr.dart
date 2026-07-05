// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appSubtitle => 'Journal mensuel en pulaar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get noAccountSignUp => 'Pas de compte ? S\'inscrire';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get passwordTooShort => 'Au moins 6 caracteres';

  @override
  String get createAccount => 'Creer un compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneOptional => 'Telephone (optionnel)';

  @override
  String get phoneHelper => 'Utile pour le paiement Bankily / Wave';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get accountCreated => 'Compte cree ! Verifiez votre email si demande.';

  @override
  String get subscribeTitle => 'Abonnez-vous a Fooyre Ɓamtaare';

  @override
  String get subscribeBody =>
      'Pour lire toutes les editions, contactez l\'editeur pour un abonnement (Bankily, Wave, virement...). Votre acces sera active des reception du paiement.';

  @override
  String get free => 'Gratuit';

  @override
  String get subscribers => 'Abonnes';

  @override
  String get loadError =>
      'Erreur de chargement.\nTirez vers le bas pour reessayer.';

  @override
  String get noEditions => 'Aucune edition disponible pour le moment.';

  @override
  String get noFreeEditions =>
      'Aucune edition gratuite disponible.\nAbonnez-vous pour acceder au journal.';

  @override
  String get downloadingEdition => 'Telechargement de l\'edition...';

  @override
  String get pdfOpenError =>
      'Impossible d\'ouvrir cette edition.\nVerifiez votre connexion ou votre abonnement.';

  @override
  String get retry => 'Reessayer';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get noPhone => 'Pas de telephone';

  @override
  String get noName => '(sans nom)';

  @override
  String get subActive => 'Abonnement actif';

  @override
  String get subInactive => 'Pas d\'abonnement actif';

  @override
  String subExpiresOn(String date, int days) {
    return 'Expire le $date ($days jours restants)';
  }

  @override
  String get subscribeContact =>
      'Pour vous abonner, contactez l\'editeur du journal (Bankily, Wave, virement...). Votre acces sera active des reception du paiement.';

  @override
  String get adminAccount => 'Compte administrateur';

  @override
  String get adminUnlimited => 'Acces illimite a toutes les editions';

  @override
  String get signOut => 'Se deconnecter';

  @override
  String get language => 'Langue';

  @override
  String subscriptionOf(String name) {
    return 'Abonnement de $name';
  }

  @override
  String get setEndDate => 'Definir la date de fin...';

  @override
  String get editEndDate => 'Modifier la date de fin...';

  @override
  String get deactivateAccess => 'Desactiver l\'acces';

  @override
  String get accessDeactivated => 'Acces desactive.';

  @override
  String get endDateHelp => 'Date de fin de l\'abonnement';

  @override
  String subUntil(String date) {
    return 'Abonnement actif jusqu\'au $date.';
  }

  @override
  String get noSubscription => 'Pas d\'abonnement';

  @override
  String expiresOn(String date) {
    return 'Expire $date';
  }

  @override
  String get expiresSoon => 'bientot !';

  @override
  String get publishEdition => 'Publier une edition';

  @override
  String get editionNumber => 'Numero de l\'edition';

  @override
  String get editionNumberHint => 'ex : 262';

  @override
  String get invalidNumber => 'Numero invalide';

  @override
  String get title => 'Titre';

  @override
  String get titleHint => 'ex : Fooyre Ɓamtaare 262';

  @override
  String get titleRequired => 'Titre requis';

  @override
  String get freeEdition => 'Edition gratuite';

  @override
  String get freeEditionSubtitle => 'Accessible a tous, meme sans abonnement';

  @override
  String get choosePdf => 'Choisir le fichier PDF';

  @override
  String get publish => 'Publier';

  @override
  String get publishing => 'Publication...';

  @override
  String get chooseFileFirst => 'Choisissez d\'abord un fichier PDF.';

  @override
  String get editionPublished => 'Edition publiee !';

  @override
  String get publishedEditions => 'Editions publiees';

  @override
  String get deleteEditionTitle => 'Supprimer cette edition ?';

  @override
  String deleteEditionBody(int numero, String titre) {
    return 'N°$numero — $titre\n\nLe fichier PDF et l\'edition seront supprimes definitivement.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get editionDeleted => 'Edition supprimee.';

  @override
  String get noEditionsYet => 'Aucune edition publiee pour le moment.';

  @override
  String get loadErrorEditions => 'Erreur de chargement des editions.';

  @override
  String get navEditions => 'Editions';

  @override
  String get navSubscribers => 'Abonnes';

  @override
  String get navPublish => 'Publier';

  @override
  String get navProfile => 'Profil';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }
}
