#!/bin/bash

LATEST_UBUNTU_LTS_VERSION="ubuntu2404"
LATEST_LINUX_MINT_VERSION="linuxmint223zena"
LATEST_DEBIAN_VERSION="debian131"
ALL_VERSIONS=("ubuntu2204" "ubuntu2404" "ubuntu2504" "linuxmint222zara" "linuxmint223zena" "debian131")
VERSIONS=("$LATEST_LINUX_MINT_VERSION") # Default to testing only on the latest Linux Mint version
ALL=false
CLEAN=false

print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  ubuntu   Run tests for the latest Ubuntu LTS version (${LATEST_UBUNTU_LTS_VERSION})"
    echo "  debian   Run tests for the latest Debian version (${LATEST_DEBIAN_VERSION})"
    echo "  all      Run tests for all VMs like ${ALL_VERSIONS[*]}"
    echo "  clean    Destroy existing Vagrant VMs before starting new ones"
    echo "  help     Show this help message"
    echo " Examples:"
    echo "  $0                 # Test only on the latest Linux Mint version (default)"
    echo "  $0 ubuntu          # Test only on the latest Ubuntu LTS version"
    echo "  $0 debian          # Test only on the latest Debian version"
    echo "  $0 all             # Test on all defined versions"
    echo "  $0 clean all       # Clean up existing VMs and test on all versions"
}

for arg in "$@"; do
    case "$arg" in
        ubuntu)
            VERSIONS=("$LATEST_UBUNTU_LTS_VERSION")
            ;;
        debian)
            VERSIONS=("$LATEST_DEBIAN_VERSION")
            ;;
        all)
            ALL=true
            VERSIONS=("${ALL_VERSIONS[@]}")
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
    echo "Running Ansible tests for ${VERSIONS[0]}..."
    ansible-playbook test_run.yml --limit "${VERSIONS[0]}"
fi
