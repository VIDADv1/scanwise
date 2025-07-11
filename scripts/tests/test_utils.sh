#!/bin/bash

# Test utilities

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a string contains a substring
assert_contains() {
  local haystack="$1"
  local needle="$2"
  
  if [[ "$haystack" != *"$needle"* ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$haystack' to contain '$needle'${NC}"
    exit 1
  fi
}

# Function to check if a string does not contain a substring
assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  
  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$haystack' to NOT contain '$needle'${NC}"
    exit 1
  fi
}

# Function to check if two strings are equal
assert_equals() {
  local actual="$1"
  local expected="$2"
  
  if [[ "$actual" != "$expected" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected '$expected' but got '$actual'${NC}"
    exit 1
  fi
}

# Function to check if a file exists
assert_file_exists() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected file '$file' to exist${NC}"
    exit 1
  fi
}

# Function to check if a directory exists
assert_dir_exists() {
  local dir="$1"
  
  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}❌ Assertion failed: Expected directory '$dir' to exist${NC}"
    exit 1
  fi
}

# Function to check if a command succeeds
assert_success() {
  local cmd="$1"
  
  if ! eval "$cmd"; then
    echo -e "${RED}❌ Assertion failed: Expected command '$cmd' to succeed${NC}"
    exit 1
  fi
}

# Function to check if a command fails
assert_failure() {
  local cmd="$1"
  
  if eval "$cmd"; then
    echo -e "${RED}❌ Assertion failed: Expected command '$cmd' to fail${NC}"
    exit 1
  fi
}

# Display an informational message
info() {
  echo -e "${YELLOW}ℹ️ $1${NC}"
}
