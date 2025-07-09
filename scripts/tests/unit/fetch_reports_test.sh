#!/bin/bash

# Tests unitaires pour fetch-reports.sh

# Importer le script de test
source "$(dirname "$0")/../test_utils.sh"

# Chemin vers le script à tester
FETCH_REPORTS_SCRIPT="$(dirname "$0")/../../fetch-reports.sh"

test_create_overall_issues_report_json() {
  # Mock des commandes curl avec une structure de pagination valide
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_create_overall_issues_report_json passed"
}

test_create_pr_issues_report_json() {
  # Mock des commandes curl et fonctions de date avec une structure de pagination valide
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "creationDate": "2023-01-01T12:00:00+0000", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Créer des fichiers temporaires pour les résultats et entrées
  tmp_output=$(mktemp)
  tmp_input=$(mktemp)
  
  # Créer un fichier temporaire avec des dates de commit
  echo "2023-01-01T00:00:00Z user@example.com" > "$tmp_input"
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_pr_issues_report_json $tmp_output $tmp_input" 2>&1
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_output"
  content=$(cat "$tmp_output")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Nettoyer
  rm "$tmp_output" "$tmp_input"
  
  echo "✅ test_create_pr_issues_report_json passed"
}

test_create_n_days_issues_report_json() {
  # Mock des commandes curl avec une structure de pagination valide
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "creationDate": "2023-01-01T12:00:00+0000", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_n_days_issues_report_json $tmp_file 30" 2>&1
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_create_n_days_issues_report_json passed"
}

test_null_pagination_handling() {
  # Mock des commandes curl avec une pagination null
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": null}}'
    return 0
  }
  export -f curl

  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"

  # Cette commande ne devrait pas échouer même avec une pagination null
  output=$(bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1)
  
  # Vérifier que la commande s'est exécutée sans erreur
  assert_not_contains "$output" "integer expression expected"
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_null_pagination_handling passed"
}

test_empty_response_handling() {
  # Mock des commandes curl avec une réponse vide
  function curl {
    echo '{"issues": [], "paging": {"pageIndex": 1, "pageSize": 500, "total": 0}}'
    return 0
  }
  export -f curl
  
  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1
  
  # Vérifier que le fichier a été créé
  assert_file_exists "$tmp_file"
  
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_empty_response_handling passed"
}

test_create_overall_hotspots_report_json() {
  # Mock des commandes curl avec une structure de pagination valide
  function curl {
    echo '{"hotspots": [{"vulnerabilityProbability": "MEDIUM", "component": "test:file", "message": "Test hotspot"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_hotspots_report_json $tmp_file" 2>&1
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_file"

  # Le format du fichier est une liste d'objets de hotspots (pas la clé "hotspots")
  # Le contenu ressemblera à : [{"vulnerabilityProbability":"MEDIUM","component":"test:file","message":"Test hotspot"}]
  content=$(cat "$tmp_file")

  # Vérifier le contenu en recherchant les propriétés d'un hotspot
  assert_contains "$content" "vulnerabilityProbability"
  assert_contains "$content" "MEDIUM"
  assert_contains "$content" "Test hotspot"
  
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_create_overall_hotspots_report_json passed"
}

test_hotspots_null_pagination_handling() {
  # Mock des commandes curl avec une pagination null
  function curl {
    echo '{"hotspots": [{"vulnerabilityProbability": "MEDIUM", "component": "test:file", "message": "Test hotspot"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": null}}'
    return 0
  }
  export -f curl
  
  # Créer un fichier temporaire pour le résultat
  tmp_file=$(mktemp)
  
  # Exécuter la fonction avec un mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  # Cette commande ne devrait pas échouer même avec une pagination null
  output=$(bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_hotspots_report_json $tmp_file" 2>&1)
  
  # Vérifier que la commande s'est exécutée sans erreur
  assert_not_contains "$output" "integer expression expected"
  
  # Vérifier que le fichier a été créé et contient les données attendues
  assert_file_exists "$tmp_file"
  
  # Nettoyer
  rm "$tmp_file"
  
  echo "✅ test_hotspots_null_pagination_handling passed"
}

# Exécuter tous les tests
run_tests() {
  test_create_overall_issues_report_json
  test_create_pr_issues_report_json
  test_create_n_days_issues_report_json
  test_null_pagination_handling
  test_empty_response_handling
  test_create_overall_hotspots_report_json
  test_hotspots_null_pagination_handling
  
  echo "✅ All fetch-reports.sh tests passed"
}

# Exécuter les tests
run_tests
