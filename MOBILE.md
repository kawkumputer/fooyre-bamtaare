# Travailler sur Fooyre Ɓamtaare depuis ton téléphone

Ce guide explique comment continuer à développer l'app **sans allumer ton PC**,
en utilisant Claude Code depuis le navigateur de ton téléphone.

## En bref

Tout ce qui compte est déjà dans le cloud :

- **Code** → GitHub : `kawkumputer/fooyre-bamtaare`
- **Build iOS / TestFlight** → GitHub Actions (secrets stockés sur GitHub)
- **Base de données + PDF** → Supabase

Donc depuis ton téléphone tu peux demander une modification, la faire valider,
et déclencher un nouveau build TestFlight — sans jamais toucher à ton ordinateur.

## Étapes

### 1. Ouvrir Claude Code sur le web
- Va sur **claude.ai/code** depuis le navigateur du téléphone.
- Sélectionne le dépôt **`kawkumputer/fooyre-bamtaare`**.

### 2. Donner tes instructions
Écris ce que tu veux en langage naturel, par exemple :
- « Ajoute un bouton de partage sur l'écran de lecture d'une édition. »
- « Change la couleur principale en bleu. »
- « Corrige le bug X sur l'écran des abonnés. »

Claude code dans un environnement cloud, puis ouvre une **Pull Request (PR)**.

### 3. Relire et fusionner la PR
- Ouvre la PR sur GitHub (lien fourni par Claude).
- Vérifie les changements, puis **Merge** (fusionner) dans `master`.

### 4. Déclencher un nouveau build TestFlight
Deux façons, les deux faisables depuis le téléphone :

**Option A — par tag (recommandé)**
Sur GitHub → onglet **Tags** ou **Releases** → créer un tag qui commence par `v`,
en incrémentant à chaque fois : `v1.0.1`, `v1.0.2`, etc.
Le workflow iOS se lance automatiquement.

**Option B — manuellement**
GitHub → onglet **Actions** → workflow « Fooyre Bamtaare iOS » → **Run workflow**.

### 5. IMPORTANT : incrémenter le numéro de build
Apple **refuse** deux fois le même numéro de build. Avant chaque nouveau build,
il faut augmenter le numéro dans [`pubspec.yaml`](pubspec.yaml) :

```yaml
version: 1.0.0+2   # -> passer à 1.0.0+3, puis +4, etc.
```

Le chiffre après le `+` est le numéro de build. Tu peux simplement demander à
Claude : « Incrémente le numéro de build avant le prochain déploiement. »

## Ce que tu NE peux PAS faire depuis le téléphone

| Action | Pourquoi |
|---|---|
| `flutter run` (test visuel en local) | Pas d'appareil/émulateur dans le cloud → utilise **TestFlight** pour tester |
| Accès aux certificats iOS (disque `D:`) | Ils restent sur ton PC (mais GitHub a déjà ce qu'il faut pour builder) |
| Accès aux secrets Supabase locaux | Non nécessaires pour coder l'app ; déjà configurés |

## Suivre un build

- **GitHub → Actions** : voir si le build CI a réussi ou échoué.
- **App Store Connect → TestFlight** : voir le build apparaître (statut
  « Processing » puis prêt à tester).

## Rappels utiles

- **Bundle id** : `org.fbpm.fooyreApp`
- **Team Apple** : `94VW99RYDQ`
- **Profil de provisioning** : `Fooyre App`
- **Compte admin de l'app** : `fooyre.bamtaare.app@gmail.com`
- Pour promouvoir un utilisateur admin, voir le bas de
  [`supabase/schema.sql`](supabase/schema.sql).
