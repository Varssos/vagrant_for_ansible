#!/bin/bash

VERSIONS=("ubuntu2404") # Default to testing only the latest LTS version
ALL=false
CLEAN=false

print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  all     Run tests for all versions (22.04, 24.04, 25.04)"
    echo "  clean   Destroy existing Vagrant VMs before starting new ones"
    echo "  help    Show this help message"
}

for arg in "$@"; do
    case "$arg" in
        all)
            ALL=true
            VERSIONS=("ubuntu2204" "ubuntu2404" "ubuntu2504")
            ;;
        clean)
            CLEAN=true
            ;;
        help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            print_help
            exit 1
            ;;
    esac
done


ROOT_DIR=$(pwd)

# Clean up existing Vagrant VMs if passed `clean` argument
if [ "$CLEAN" = true ]; then
    for v in "${VERSIONS[@]}"; do
        echo "Destroying Vagrant VM for ${v}..."
        vagrant destroy -f "${v}"
    done
fi

for v in "${VERSIONS[@]}"; do
    echo "Starting Vagrant VM for ${v}..."
    vagrant up "${v}" || { echo "Failed to start VM for ${v}"; exit 1; }
done

# Return to project root and run ansible tests
cd "${ROOT_DIR}/.."
if [ "$ALL" = true ]; then
    echo "Running Ansible tests for all versions..."
    ansible-playbook test_run.yml
else
    echo "Running Ansible tests for Ubuntu 24.04..."
    ansible-playbook test_run.yml --limit "ubuntu2404"
fi
