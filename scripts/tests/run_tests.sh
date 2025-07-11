#!/bin/bash

# Script to run all unit and integration tests

# Root test directory
TEST_ROOT="$(dirname "$0")"

# Import test utilities
source "$TEST_ROOT/test_utils.sh"

# Function to display test start banner
display_banner() {
  local title="$1"
  local separator=$(printf '=%.0s' {1..50})
  
  echo -e "\n$separator"
  echo -e "📋 $title"
  echo -e "$separator\n"
}

# Function to run all unit tests
run_unit_tests() {
  display_banner "Running unit tests"
  
  # Find all unit test scripts
  for test_file in "$TEST_ROOT/unit/"*_test.sh; do
    if [[ -f "$test_file" ]]; then
      echo -e "🔍 Running $(basename "$test_file")..."
      chmod +x "$test_file"
      if "$test_file"; then
        echo -e "✅ $(basename "$test_file") successful\n"
      else
        echo -e "❌ $(basename "$test_file") failed\n"
        exit 1
      fi
    fi
  done
  
  echo -e "✅ All unit tests passed"
}

# Main function
main() {
  display_banner "Test Suite for Scanwise Code Analysis"
  
  # Create directory structure if it doesn't exist
  mkdir -p "$TEST_ROOT/unit"
  
  # Make all scripts executable
  chmod +x "$TEST_ROOT/test_utils.sh"
  
  # Run tests
  run_unit_tests

  display_banner "All tests passed! 🎉"
}

# Run the main program
main "$@"
