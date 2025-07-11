#!/bin/bash

# Unit tests for generate-summary-and-reports.sh

# Import test script
source "$(dirname "$0")/../test_utils.sh"

# Path to the script to test
GENERATE_SUMMARY_SCRIPT="$(dirname "$0")/../../generate-summary-and-reports.sh"

test_generate_issues_report_md() {
  # Create temporary files for input and output
  input_file=$(mktemp)
  output_file=$(mktemp)
  
  # Create a JSON input file with test data (array format expected by jq)
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
  
  # Execute the function to test
  export SONAR_PROJECT_NAME="tests"
  bash -c "source $GENERATE_SUMMARY_SCRIPT && generate_issues_report_md $input_file $output_file" 2>&1
  
  # Check that the output file was created and contains the expected data
  assert_file_exists "$output_file"
  content=$(cat "$output_file")
  assert_contains "$content" "### 🌟 **Scanwise overall Issues Details for tests** 🌟"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Clean up
  rm "$input_file" "$output_file"
  
  echo "✅ test_generate_issues_report_md passed"
}

test_generate_hotspots_report_md() {
  # Create temporary files for input and output
  input_file=$(mktemp)
  output_file=$(mktemp)
  
  # Create a JSON input file with test data (array format expected by jq)
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
  
  # Execute the function to test
  export SONAR_PROJECT_NAME="tests"
  bash -c "source $GENERATE_SUMMARY_SCRIPT && generate_hotspots_report_md $input_file $output_file" 2>&1
  
  # Check that the output file was created and contains the expected data
  assert_file_exists "$output_file"
  content=$(cat "$output_file")
  assert_contains "$content" "### 🌟 **Scanwise overall security hotspots to review for tests** 🌟"
  assert_contains "$content" "MEDIUM"
  assert_contains "$content" "Test hotspot"
  
  # Clean up
  rm "$input_file" "$output_file"
  
  echo "✅ test_generate_hotspots_report_md passed"
}

# Run all tests
run_tests() {
  test_generate_issues_report_md
  test_generate_hotspots_report_md

  echo "✅ All generate-summary-and-reports.sh tests passed"
}

# Run tests
run_tests
