#!/bin/bash

# Script pour exécuter tous les tests unitaires et d'intégration

# Répertoire racine des tests
TEST_ROOT="$(dirname "$0")"

# Importer les utilitaires de test
source "$TEST_ROOT/test_utils.sh"

# Fonction pour afficher la bannière de début de test
display_banner() {
  local title="$1"
  local separator=$(printf '=%.0s' {1..50})
  
  echo -e "\n$separator"
  echo -e "📋 $title"
  echo -e "$separator\n"
}

# Fonction pour exécuter tous les tests unitaires
run_unit_tests() {
  display_banner "Exécution des tests unitaires"
  
  # Trouver tous les scripts de test unitaire
  for test_file in "$TEST_ROOT/unit/"*_test.sh; do
    if [[ -f "$test_file" ]]; then
      echo -e "🔍 Exécution de $(basename "$test_file")..."
      chmod +x "$test_file"
      if "$test_file"; then
        echo -e "✅ $(basename "$test_file") réussi\n"
      else
        echo -e "❌ $(basename "$test_file") échoué\n"
        exit 1
      fi
    fi
  done
  
  echo -e "✅ Tous les tests unitaires sont réussis"
}

# Fonction principale
main() {
  display_banner "Test Suite pour Sonarless Code Analysis"
  
  # Créer la structure de répertoires si elle n'existe pas
  mkdir -p "$TEST_ROOT/unit"
  
  # Rendre tous les scripts exécutables
  chmod +x "$TEST_ROOT/test_utils.sh"
  
  # Exécuter les tests
  run_unit_tests

  display_banner "Tous les tests sont réussis! 🎉"
}

# Exécuter le programme principal
main "$@"
