#!/bin/bash

# Utilitaires pour les tests

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour vérifier si une chaîne contient une sous-chaîne
assert_contains() {
  local haystack="$1"
  local needle="$2"
  
  if [[ "$haystack" != *"$needle"* ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$haystack' to contain '$needle'${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si une chaîne ne contient pas une sous-chaîne
assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  
  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$haystack' to NOT contain '$needle'${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si deux chaînes sont égales
assert_equals() {
  local actual="$1"
  local expected="$2"
  
  if [[ "$actual" != "$expected" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$expected' but got '$actual'${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si un fichier existe
assert_file_exists() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected file '$file' to exist${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si un répertoire existe
assert_dir_exists() {
  local dir="$1"
  
  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected directory '$dir' to exist${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si une commande réussit
assert_success() {
  local cmd="$1"
  
  if ! eval "$cmd"; then
    echo -e "${RED}❌ Assertion failed: Expected command '$cmd' to succeed${NC}"
    exit 1
  fi
}

# Fonction pour vérifier si une commande échoue
assert_failure() {
  local cmd="$1"
  
  if eval "$cmd"; then
    echo -e "${RED}❌ Assertion failed: Expected command '$cmd' to fail${NC}"
    exit 1
  fi
}

# Afficher un message d'information
info() {
  echo -e "${YELLOW}ℹ️ $1${NC}"
}
