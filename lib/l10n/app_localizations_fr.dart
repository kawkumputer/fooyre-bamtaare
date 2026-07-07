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
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get noAccountSignUp => 'Pas de compte ? S\'inscrire';

  @override
  String get invalidEmail => 'E-mail invalide';

  @override
  String get passwordTooShort => 'Au moins 6 caractères';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneOptional => 'Téléphone (optionnel)';

  @override
  String get phoneHelper => 'Utile pour le paiement Bankily / Wave';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get accountCreated =>
      'Compte créé ! Vous pouvez vous connecter dès maintenant.';

  @override
  String get subscribeTitle => 'Abonnez-vous à Fooyre Ɓamtaare';

  @override
  String get subscribeBody =>
      'Pour lire toutes les éditions, contactez l\'éditeur pour un abonnement (Bankily, Wave, virement...). Votre accès sera activé dès réception du paiement.';

  @override
  String get free => 'Gratuit';

  @override
  String get subscribers => 'Abonnés';

  @override
  String get loadError =>
      'Erreur de chargement.\nTirez vers le bas pour réessayer.';

  @override
  String get noEditions => 'Aucune édition disponible pour le moment.';

  @override
  String get noFreeEditions =>
      'Aucune édition gratuite disponible.\nAbonnez-vous pour accéder au journal.';

  @override
  String get downloadingEdition => 'Téléchargement de l\'édition...';

  @override
  String get pdfOpenError =>
      'Impossible d\'ouvrir cette édition.\nVérifiez votre connexion ou votre abonnement.';

  @override
  String get retry => 'Réessayer';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get noPhone => 'Pas de téléphone';

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
      'Pour vous abonner, contactez l\'éditeur du journal (Bankily, Wave, virement...). Votre accès sera activé dès réception du paiement.';

  @override
  String get adminAccount => 'Compte administrateur';

  @override
  String get adminUnlimited => 'Accès illimité à toutes les éditions';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get language => 'Langue';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get deleteMyAccountConfirmTitle =>
      'Supprimer définitivement votre compte ?';

  @override
  String get deleteMyAccountConfirmBody =>
      'Cette action est irréversible. Votre profil, votre abonnement et toutes vos données seront supprimés définitivement.';

  @override
  String get myAccountDeleted => 'Votre compte a été supprimé.';

  @override
  String get confirmUserEmail => 'Confirmer l\'e-mail';

  @override
  String get userEmailConfirmed => 'E-mail confirmé.';

  @override
  String get emailNotConfirmed => 'E-mail non confirmé';

  @override
  String get deleteUserAccount => 'Supprimer le compte';

  @override
  String get deleteUserConfirmTitle => 'Supprimer ce compte ?';

  @override
  String deleteUserConfirmBody(String name) {
    return 'Le compte de $name sera supprimé définitivement, avec toutes ses données. Cette action est irréversible.';
  }

  @override
  String get userAccountDeleted => 'Compte supprimé.';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get profileUpdated => 'Profil mis à jour.';

  @override
  String get emailNotEditable => 'L\'e-mail ne peut pas être modifié.';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour.';

  @override
  String get subscribeForFull => 'Abonnez-vous pour lire l\'édition complète';

  @override
  String get editionComplete => 'Édition complète';

  @override
  String get chooseFullPdf => 'PDF complet (abonnés)';

  @override
  String get chooseCoverImage => 'Affiche (image de la une)';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get chooseFromFiles => 'Choisir depuis les fichiers';

  @override
  String get coverLabel => 'Affiche';

  @override
  String get coverAndPdfRequired =>
      'L\'affiche et le PDF complet sont tous les deux obligatoires.';

  @override
  String get publicationDate => 'Date de parution';

  @override
  String publishedOn(String date) {
    return 'Paru le $date';
  }

  @override
  String get subscribeDialogTitle => 'Édition complète';

  @override
  String get subscribeDialogBody =>
      'Pour lire l\'édition complète, vous devez être abonné. Contactez l\'éditeur pour obtenir l\'accès (Bankily, Wave, virement...).';

  @override
  String get close => 'Fermer';

  @override
  String get editionUnavailable => 'Édition indisponible pour le moment.';

  @override
  String subscriptionOf(String name) {
    return 'Abonnement de $name';
  }

  @override
  String get setEndDate => 'Définir la date de fin...';

  @override
  String get editEndDate => 'Modifier la date de fin...';

  @override
  String get deactivateAccess => 'Désactiver l\'accès';

  @override
  String get accessDeactivated => 'Accès désactivé.';

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
    return 'Expire le $date';
  }

  @override
  String get expiresSoon => 'bientôt !';

  @override
  String get publishEdition => 'Publier une édition';

  @override
  String get editionNumber => 'Numéro de l\'édition';

  @override
  String get editionNumberHint => 'ex : 262';

  @override
  String get invalidNumber => 'Numéro invalide';

  @override
  String get title => 'Titre';

  @override
  String get titleHint => 'ex : Tonngoode 262';

  @override
  String get titleRequired => 'Titre requis';

  @override
  String get freeEdition => 'Édition gratuite';

  @override
  String get freeEditionSubtitle => 'Accessible à tous, même sans abonnement';

  @override
  String get choosePdf => 'Choisir le fichier PDF';

  @override
  String get publish => 'Publier';

  @override
  String get publishing => 'Publication...';

  @override
  String get chooseFileFirst => 'Choisissez d\'abord un fichier PDF.';

  @override
  String get editionPublished => 'Édition publiée !';

  @override
  String get publishedEditions => 'Éditions publiées';

  @override
  String get deleteEditionTitle => 'Supprimer cette édition ?';

  @override
  String deleteEditionBody(int numero, String titre) {
    return 'N°$numero — $titre\n\nLe fichier PDF et l\'édition seront supprimés définitivement.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get editionDeleted => 'Édition supprimée.';

  @override
  String get noEditionsYet => 'Aucune édition publiée pour le moment.';

  @override
  String get loadErrorEditions => 'Erreur de chargement des éditions.';

  @override
  String get searchEditionHint => 'Rechercher par numéro';

  @override
  String get searchUserHint => 'Rechercher par nom ou téléphone';

  @override
  String get noSearchResult => 'Aucun résultat.';

  @override
  String get navEditions => 'Éditions';

  @override
  String get navSubscribers => 'Abonnés';

  @override
  String get navPublish => 'Publier';

  @override
  String get navProfile => 'Profil';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }
}
