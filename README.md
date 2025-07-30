# Decentralized Stable Coin (DSC) 🪙

Un système de stablecoin décentralisé entièrement collatéralisé, ancré au dollar américain et gouverné algorithmiquement.

## 🎯 Vue d'ensemble

DSC (Decentralized Stable Coin) est un stablecoin crypto-collatéralisé conçu pour maintenir une parité stable avec le dollar américain (1 DSC = 1 USD). Le système est inspiré du protocole MakerDAO/DAI mais simplifié, sans gouvernance décentralisée.

### Caractéristiques principales

- **🔗 Ancrage stable** : Maintien d'une parité 1:1 avec l'USD
- **💎 Collatéral exogène** : Supporté par ETH et WBTC
- **🤖 Stabilité algorithmique** : Pas de gouvernance centralisée
- **🛡️ Sur-collatéralisation** : Système de sécurité robuste
- **⚡ Liquidation automatique** : Protection contre les risques de sous-collatéralisation

## 🏗️ Architecture

Le système se compose de deux contrats principaux :

### DSCEngine.sol
Le cœur du système qui gère :
- Dépôt et retrait de collatéral (ETH/WBTC)
- Frappe et destruction de tokens DSC
- Calcul du facteur de santé des positions
- Mécanisme de liquidation automatique
- Intégration des oracles Chainlink pour les prix

### DecentralizedStableCoin.sol
Le token ERC20 DSC avec :
- Fonctionnalités de mint/burn contrôlées
- Propriété exclusive par le DSCEngine
- Conformité aux standards OpenZeppelin

## 📊 Mécanismes clés

### Facteur de santé
```
Health Factor = (Collateral Value × Liquidation Threshold) / DSC Minted
```
- **Seuil minimum** : 1.0
- **Seuil de liquidation** : 50% de la valeur du collatéral
- **Bonus de liquidation** : 10% pour les liquidateurs

### Processus de frappe
1. Dépôt de collatéral (ETH/WBTC)
2. Vérification du ratio de collatéralisation
3. Frappe des tokens DSC
4. Maintien du facteur de santé > 1.0

### Liquidation
- Déclenchée quand le facteur de santé < 1.0
- Les liquidateurs reçoivent un bonus de 10%
- Protection du système contre l'insolvabilité

## 🔧 Fonctionnalités

### Pour les utilisateurs
- `depositCollateralAndMintDsc()` - Dépôt et frappe en une transaction
- `redeemCollateralForDsc()` - Remboursement et retrait en une transaction
- `depositCollateral()` - Dépôt de collatéral uniquement
- `mintDsc()` - Frappe de DSC uniquement
- `redeemCollateral()` - Retrait de collatéral
- `burnDsc()` - Destruction de DSC

### Pour les liquidateurs
- `liquidate()` - Liquidation des positions à risque

### Fonctions de consultation
- `getHealthFactor()` - Facteur de santé d'un utilisateur
- `getAccountCollateralValue()` - Valeur totale du collatéral
- `getTokenAmountFromUsd()` - Conversion USD vers tokens

## 🛡️ Sécurité & Qualité

### Bonnes Pratiques Implémentées
- **Protection contre la réentrance** : Utilisation d'OpenZeppelin ReentrancyGuard
- **Pattern CEI** : Check-Effects-Interactions respecté dans toutes les fonctions
- **Validations strictes** : Modifiers personnalisés pour les montants et tokens
- **Gestion d'erreurs robuste** : Erreurs custom explicites et informatives

### Tests de Sécurité Avancés
- **Fuzzing property-based** avec Handler intelligent
- **Tests d'invariants automatisés** sur les propriétés critiques
- **Simulation d'attaques** via scénarios de test adversariaux
- **Validation des oracles** avec mocks Chainlink

### Oracles & Prix
- **Chainlink Price Feeds** décentralisés et fiables
- **Protection contre les prix stales** via `OracleLib`
- **Conversion de précision** gérée automatiquement
- **Validation des prix** avant chaque opération critique

## 🧪 Tests & Technologie

### Stack Technique
- **Solidity ^0.8.20** - Langage de programmation principal
- **Foundry** - Framework de développement et test
- **OpenZeppelin** - Librairies de sécurité standard
- **Chainlink** - Oracles de prix décentralisés

### Suite de Tests Avancée

#### Tests d'Invariants (`InvariantsTest.t.sol`)
Vérification automatique des propriétés critiques du système :
```solidity
// Invariant principal : Le collatéral doit toujours dépasser la supply de DSC
function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
    uint256 totalSupply = dsc.totalSupply();
    uint256 totalCollateralValue = wethValue + wbtcValue;
    assert(totalCollateralValue >= totalSupply);
}
```

#### Handler de Fuzzing (`Handler.t.sol`)
- **Fuzzing intelligent** avec contraintes réalistes
- **Simulation d'utilisateurs** avec dépôts et retraits aléatoires
- **Protection contre les cas extrêmes** via `bound()` et validations
- **Calcul de sécurité** pour les retraits maximum autorisés

#### Tests Unitaires (`DSCEngineTest.t.sol`)
- Tests de constructeur et validation des paramètres
- Tests de conversion de prix et oracles
- Tests de dépôt de collatéral avec modifiers
- Scénarios d'erreur et cas limites

### Fonctionnalités de Test Avancées

**🎯 Fuzzing Property-Based**
- Génération automatique de cas de test
- Validation continue des invariants système
- Protection contre les edge cases imprévisibles

**🔍 Mocking Sophistiqué**
- `ERC20Mock` pour tokens de test
- `MockV3Aggregator` pour simulation d'oracles
- Environnement de test isolé et reproductible

**📊 Métriques de Qualité**
- Tracking des appels critiques (`timesMintIsCalled`)
- Logging détaillé des valeurs système
- Assertions robustes sur les ratios de collatéralisation

## 🚀 Déploiement

### Prérequis
- **Foundry** - `curl -L https://foundry.paradigm.xyz | bash`
- **Solidity ^0.8.20**
- **Git** pour le clonage des dépendances

### Installation
```bash
git clone <votre-repo>
cd dsc-project
forge install
forge build
```

### Tests
```bash
# Tests unitaires
forge test

# Tests avec fuzzing
forge test --fuzz-runs 1000

# Tests d'invariants
forge test --match-contract InvariantsTest

# Coverage
forge coverage
```

### Configuration
Le déploiement nécessite :
- Adresses des tokens de collatéral (WETH, WBTC)
- Adresses des price feeds Chainlink correspondants
- Script de déploiement avec `HelperConfig` pour multi-chaînes

## ⚡ Innovations Techniques

### Architecture Modulaire
- **Séparation des responsabilités** : Engine vs Token contract
- **Interfaces standardisées** : Compatibilité ERC20 complète
- **Extensibilité** : Ajout facile de nouveaux collatéraux

### Optimisations Gaz
- **Calculs efficaces** : Utilisation de constantes pour les ratios
- **Storage packing** : Optimisation des variables d'état
- **Batch operations** : Fonctions combinées (deposit + mint)

### Gestion des Liquidations
```solidity
// Bonus de liquidation intelligent (10%)
uint256 bonusCollateral = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;
```

### Handler de Fuzzing Avancé
- **Calcul dynamique des limites sûres** pour les retraits
- **Simulation réaliste d'utilisateurs** avec états persistants
- **Gestion intelligente des edge cases** via bounds et validations

## 📊 Métriques & Monitoring

### Tableaux de Bord
- **Health Factor** : Monitoring en temps réel des positions
- **Collateralization Ratio** : Suivi global du système
- **Liquidation Events** : Alertes automatiques

### Analytics On-Chain
- Events détaillés pour tracking des dépôts/retraits
- Logging des liquidations avec bonus
- Métriques de performance des tests de fuzzing

- **DeFi** : Collatéral pour prêts et emprunts
- **Trading** : Monnaie stable pour les échanges
- **Épargne** : Réserve de valeur stable
- **Liquidité** : Provision dans les pools AMM

## ⚠️ Risques

- **Risque de liquidation** : En cas de chute des prix du collatéral
- **Risque d'oracle** : Dépendance aux prix Chainlink
- **Risque de smart contract** : Bugs potentiels dans le code
- **Risque de gouvernance** : Système sans gouvernance décentralisée

## 🔮 Feuille de route

- [ ] Tests exhaustifs et audit de sécurité
- [ ] Interface utilisateur web3
- [ ] Support de tokens de collatéral additionnels
- [ ] Mécanismes de gouvernance décentralisée
- [ ] Intégration avec d'autres protocoles DeFi

## 📄 Licence

MIT License - voir le fichier LICENSE pour plus de détails.

---

**⚠️ Avertissement** : Ce projet est à des fins éducatives et de recherche. Utilisez à vos propres risques en production.
