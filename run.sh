#!/bin/bash

LATEST_UBUNTU_LTS_VERSION="ubuntu2404"
LATEST_LINUX_MINT_VERSION="linuxmint223zena"
LATEST_DEBIAN_VERSION="debian131"
ALL_VERSIONS=("ubuntu2204" "ubuntu2404" "linuxmint223zena" "debian131") # ubuntu2504 linuxmint222zara currently not supported
VERSIONS=("$LATEST_LINUX_MINT_VERSION") # Default to testing only on the latest Linux Mint version
ALL=false
CLEAN=false
HALT=false
SNAPSHOT_SAVE=false
SNAPSHOT_RESTORE=false
SNAPSHOT_NAME="ansible_test_base"

print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  ubuntu            Run tests for the latest Ubuntu LTS version (${LATEST_UBUNTU_LTS_VERSION})"
    echo "  debian            Run tests for the latest Debian version (${LATEST_DEBIAN_VERSION})"
    echo "  all               Run tests for all VMs like ${ALL_VERSIONS[*]}"
    echo "  clean             Destroy existing Vagrant VMs before starting new ones (slow, full rebuild)"
    echo "  halt              Halt running VMs without destroying (fast fix for stuck VMs)"
    echo "  snap-save         Save snapshot '${SNAPSHOT_NAME}' on all target VMs after vagrant up"
    echo "  snap-restore      Restore snapshot '${SNAPSHOT_NAME}' instead of clean (fast reset, ~30s)"
    echo "  help              Show this help message"
    echo ""
    echo " Speed comparison:"
    echo "  clean all         ~10-15 min (full destroy + provision + ansible)"
    echo "  snap-restore all  ~1-2 min   (snapshot restore + ansible only)"
    echo "  all               ~30s       (start halted VMs + ansible only)"
    echo ""
    echo " Examples:"
    echo "  $0                        # Test only on the latest Linux Mint version (default)"
    echo "  $0 ubuntu                 # Test only on the latest Ubuntu LTS version"
    echo "  $0 debian                 # Test only on the latest Debian version"
    echo "  $0 ubuntu2204             # Test only on a specific version from ALL_VERSIONS"
    echo "  $0 all                    # Test on all defined versions"
    echo "  $0 halt all               # Halt stuck VMs, then re-run tests on all"
    echo "  $0 clean all              # Full rebuild — use only when provisioning is broken"
    echo "  $0 snap-save all          # Save base snapshot after first successful provisioning"
    echo "  $0 snap-restore all       # Restore base snapshot (fast alternative to clean)"
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
        halt)
            HALT=true
            ;;
        snap-save)
            SNAPSHOT_SAVE=true
            ;;
        snap-restore)
            SNAPSHOT_RESTORE=true
            ;;
        help)
            print_help
            exit 0
            ;;
        *)
            # Check if argument matches one of ALL_VERSIONS
            matched=false
            for v in "${ALL_VERSIONS[@]}"; do
                if [[ "$arg" == "$v" ]]; then
                    VERSIONS=("$arg")
                    matched=true
                    break
                fi
            done
            if [[ "$matched" == false ]]; then
                echo "Unknown option: $arg"
                echo "Valid versions: ${ALL_VERSIONS[*]}"
                print_help
                exit 1
            fi
            ;;
    esac
done


ROOT_DIR=$(pwd)

# Workaround: ~/.netrc contains non-standard 'protocol'
# which causes Python's netrc parser to crash when Galaxy calls the API.
export NETRC=/dev/null

# Halt VMs (fast fix for stuck/timeout VMs — no data loss, much faster than clean)
if [ "$HALT" = true ]; then
    for v in "${VERSIONS[@]}"; do
        echo "Halting Vagrant VM for ${v}..."
        vagrant halt "${v}"
    done
fi

# Restore snapshot (fast alternative to clean — ~30s vs ~15min)
if [ "$SNAPSHOT_RESTORE" = true ]; then
    for v in "${VERSIONS[@]}"; do
        echo "Restoring snapshot '${SNAPSHOT_NAME}' for ${v}..."
        vagrant snapshot restore "${v}" "${SNAPSHOT_NAME}" --no-provision || {
            echo "No snapshot '${SNAPSHOT_NAME}' found for ${v}. Run: $0 snap-save"
            echo "Falling back to clean rebuild..."
            vagrant destroy -f "${v}"
        }
    done
fi

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

# Save snapshot after vagrant up (run once after first successful provisioning)
if [ "$SNAPSHOT_SAVE" = true ]; then
    for v in "${VERSIONS[@]}"; do
        echo "Saving snapshot '${SNAPSHOT_NAME}' for ${v}..."
        vagrant snapshot save "${v}" "${SNAPSHOT_NAME}"
    done
fi

# Return to project root and run ansible tests
cd "${ROOT_DIR}/.."
ansible-galaxy install -r requirements.yml

if [ "$ALL" = true ]; then
    echo "Running Ansible tests for all versions..."
    ansible-playbook test_run.yml
else
    echo "Running Ansible tests for ${VERSIONS[0]}..."
    ansible-playbook test_run.yml --limit "${VERSIONS[0]}"
fi
