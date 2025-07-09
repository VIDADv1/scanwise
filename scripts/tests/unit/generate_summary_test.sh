#!/bin/bash

# Tests unitaires pour generate-summary-and-reports.sh

# Importer le script de test
source "$(dirname "$0")/../test_utils.sh"

# Chemin vers le script à tester
GENERATE_SUMMARY_SCRIPT="$(dirname "$0")/../../generate-summary-and-reports.sh"

test_generate_issues_report_md() {
  # Créer des fichiers temporaires pour l'entrée et la sortie
  input_file=$(mktemp)
  output_file=$(mktemp)
  
  # Créer un fichier JSON d'entrée avec des données de test (format d'array attendu par jq)
  cat > "$input_file" << EOF
[
  {
    "type": "CODE_SMELL",
    "severity": "MAJOR",
    "component": "test:src/main/java/com/example/Test.java",
    "message": "Test issue",
    "line": 10,
    "rule": "java:S1234",
    "effort": "5min",
    "author": "test@example.com"
  }
]
EOF
  
  # Exécuter la fonction à tester
  export SONAR_PROJECT_NAME="tests"
  bash -c "source $GENERATE_SUMMARY_SCRIPT && generate_issues_report_md $input_file $output_file" 2>&1
  
  # Vérifier que le fichier de sortie a été créé et contient les données attendues
  assert_file_exists "$output_file"
  content=$(cat "$output_file")
  assert_contains "$content" "### 🌟 **Sonarless overall Issues Details for tests** 🌟"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Nettoyer
  rm "$input_file" "$output_file"
  
  echo "✅ test_generate_issues_report_md passed"
}

test_generate_hotspots_report_md() {
  # Créer des fichiers temporaires pour l'entrée et la sortie
  input_file=$(mktemp)
  output_file=$(mktemp)
  
  # Créer un fichier JSON d'entrée avec des données de test (format d'array attendu par jq)
  cat > "$input_file" << EOF
[
  {
    "vulnerabilityProbability": "MEDIUM",
    "component": "test:src/main/java/com/example/Test.java",
    "message": "Test hotspot",
    "line": 10,
    "ruleKey": "java:S1234",
    "securityCategory": "sql-injection",
    "author": "test@example.com"
  }
]
EOF
  
  # Exécuter la fonction à tester
  export SONAR_PROJECT_NAME="tests"
  bash -c "source $GENERATE_SUMMARY_SCRIPT && generate_hotspots_report_md $input_file $output_file" 2>&1
  
  # Vérifier que le fichier de sortie a été créé et contient les données attendues
  assert_file_exists "$output_file"
  content=$(cat "$output_file")
  assert_contains "$content" "### 🌟 **Sonarless overall security hotspots to review for tests** 🌟"
  assert_contains "$content" "MEDIUM"
  assert_contains "$content" "Test hotspot"
  
  # Nettoyer
  rm "$input_file" "$output_file"
  
  echo "✅ test_generate_hotspots_report_md passed"
}

# Exécuter tous les tests
run_tests() {
  test_generate_issues_report_md
  test_generate_hotspots_report_md
  
  echo "✅ All generate-summary-and-reports.sh tests passed"
}

# Exécuter les tests
run_tests
