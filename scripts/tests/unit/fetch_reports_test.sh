#!/bin/bash

# Unit tests for fetch-reports.sh

# Import test script
source "$(dirname "$0")/../test_utils.sh"

# Path to the script to test
FETCH_REPORTS_SCRIPT="$(dirname "$0")/../../fetch-reports.sh"

test_create_overall_issues_report_json() {
  # Mock curl commands with a valid pagination structure
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_create_overall_issues_report_json passed"
}

test_create_pr_issues_report_json() {
  # Mock curl commands and date functions with a valid pagination structure
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "creationDate": "2023-01-01T12:00:00+0000", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Create temporary files for results and inputs
  tmp_output=$(mktemp)
  tmp_input=$(mktemp)
  
  # Create a temporary file with commit dates
  echo "2023-01-01T00:00:00Z user@example.com" > "$tmp_input"
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_pr_issues_report_json $tmp_output $tmp_input" 2>&1
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_output"
  content=$(cat "$tmp_output")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Clean up
  rm "$tmp_output" "$tmp_input"
  
  echo "✅ test_create_pr_issues_report_json passed"
}

test_create_n_days_issues_report_json() {
  # Mock curl commands with a valid pagination structure
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "creationDate": "2023-01-01T12:00:00+0000", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_n_days_issues_report_json $tmp_file 30" 2>&1
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  assert_contains "$content" "Test issue"
  
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_create_n_days_issues_report_json passed"
}

test_null_pagination_handling() {
  # Mock curl commands with null pagination
  function curl {
    echo '{"issues": [{"severity": "MAJOR", "component": "test:file", "message": "Test issue"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": null}}'
    return 0
  }
  export -f curl

  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"

  # This command should not fail even with null pagination
  output=$(bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1)
  
  # Check that the command executed without error
  assert_not_contains "$output" "integer expression expected"
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_file"
  content=$(cat "$tmp_file")
  assert_contains "$content" "severity"
  assert_contains "$content" "MAJOR"
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_null_pagination_handling passed"
}

test_empty_response_handling() {
  # Mock curl commands with an empty response
  function curl {
    echo '{"issues": [], "paging": {"pageIndex": 1, "pageSize": 500, "total": 0}}'
    return 0
  }
  export -f curl
  
  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_issues_report_json $tmp_file" 2>&1
  
  # Check that the file was created
  assert_file_exists "$tmp_file"
  
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_empty_response_handling passed"
}

test_create_overall_hotspots_report_json() {
  # Mock curl commands with a valid pagination structure
  function curl {
    echo '{"hotspots": [{"vulnerabilityProbability": "MEDIUM", "component": "test:file", "message": "Test hotspot"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": 1}}'
    return 0
  }
  export -f curl
  
  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_hotspots_report_json $tmp_file" 2>&1
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_file"

  # The file format is a list of hotspot objects (not the "hotspots" key)
  # The content will look like: [{"vulnerabilityProbability":"MEDIUM","component":"test:file","message":"Test hotspot"}]
  content=$(cat "$tmp_file")

  # Check the content by searching for hotspot properties
  assert_contains "$content" "vulnerabilityProbability"
  assert_contains "$content" "MEDIUM"
  assert_contains "$content" "Test hotspot"
  
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_create_overall_hotspots_report_json passed"
}

test_hotspots_null_pagination_handling() {
  # Mock curl commands with null pagination
  function curl {
    echo '{"hotspots": [{"vulnerabilityProbability": "MEDIUM", "component": "test:file", "message": "Test hotspot"}], "paging": {"pageIndex": 1, "pageSize": 500, "total": null}}'
    return 0
  }
  export -f curl
  
  # Create a temporary file for the result
  tmp_file=$(mktemp)
  
  # Execute the function with a mock
  export SONAR_INSTANCE_PORT=9000
  export SONAR_PROJECT_NAME="test-project"
  
  # This command should not fail even with null pagination
  output=$(bash -c "source $FETCH_REPORTS_SCRIPT && create_overall_hotspots_report_json $tmp_file" 2>&1)
  
  # Check that the command executed without error
  assert_not_contains "$output" "integer expression expected"
  
  # Check that the file was created and contains the expected data
  assert_file_exists "$tmp_file"
  
  # Clean up
  rm "$tmp_file"
  
  echo "✅ test_hotspots_null_pagination_handling passed"
}

# Run all tests
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

# Run tests
run_tests
