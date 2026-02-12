#!/usr/bin/env bash
# Code Deployer
# Automated deployment tool for production code packages

set -euo pipefail

DEPLOY_DIR="${DEPLOY_DIR:-/opt/deployed_apps}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/deployments}"
LOG_FILE="deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

print_header() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  Code Deployer - Production Package Manager      ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
}

validate_package() {
    local package=$1
    
    if [[ ! -f "$package" ]]; then
        log "ERROR: Package not found: $package"
        return 1
    fi
    
    # Check if valid archive
    if [[ "$package" == *.tar.gz ]] || [[ "$package" == *.tgz ]]; then
        if ! tar -tzf "$package" &> /dev/null; then
            log "ERROR: Invalid tar.gz archive"
            return 1
        fi
    elif [[ "$package" == *.zip ]]; then
        if ! unzip -t "$package" &> /dev/null; then
            log "ERROR: Invalid zip archive"
            return 1
        fi
    else
        log "ERROR: Unsupported package format (use .tar.gz or .zip)"
        return 1
    fi
    
    log "✓ Package validation passed"
    return 0
}

backup_existing() {
    local app_name=$1
    local target_dir="$DEPLOY_DIR/$app_name"
    
    if [[ -d "$target_dir" ]]; then
        log "Backing up existing deployment..."
        
        mkdir -p "$BACKUP_DIR"
        local backup_file="$BACKUP_DIR/${app_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
        
        tar -czf "$backup_file" -C "$DEPLOY_DIR" "$app_name" 2>/dev/null
        log "✓ Backup saved: $backup_file"
    fi
}

extract_package() {
    local package=$1
    local temp_dir=$2
    
    log "Extracting package..."
    
    if [[ "$package" == *.tar.gz ]] || [[ "$package" == *.tgz ]]; then
        tar -xzf "$package" -C "$temp_dir"
    elif [[ "$package" == *.zip ]]; then
        unzip -q "$package" -d "$temp_dir"
    fi
    
    log "✓ Package extracted to $temp_dir"
}

run_pre_deploy_checks() {
    local deploy_dir=$1
    
    # Check for pre-deploy script
    if [[ -f "$deploy_dir/pre_deploy.sh" ]]; then
        log "Running pre-deploy checks..."
        
        cd "$deploy_dir"
        if bash pre_deploy.sh; then
            log "✓ Pre-deploy checks passed"
            return 0
        else
            log "ERROR: Pre-deploy checks failed"
            return 1
        fi
    fi
    
    return 0
}

install_dependencies() {
    local deploy_dir=$1
    
    # Check for requirements files
    if [[ -f "$deploy_dir/requirements.txt" ]]; then
        log "Installing Python dependencies..."
        pip install -q -r "$deploy_dir/requirements.txt" || log "WARNING: Some Python deps failed"
    fi
    
    if [[ -f "$deploy_dir/package.json" ]]; then
        log "Installing Node.js dependencies..."
        cd "$deploy_dir"
        npm install --silent || log "WARNING: Some Node deps failed"
    fi
    
    if [[ -f "$deploy_dir/Makefile" ]]; then
        log "Running make install..."
        cd "$deploy_dir"
        make install || log "WARNING: Make install had issues"
    fi
}

deploy_package() {
    local package=$1
    local app_name=$2
    
    if [[ -z "$app_name" ]]; then
        app_name=$(basename "$package" | sed 's/\.[^.]*$//')
    fi
    
    log "Deploying: $app_name"
    log "Package:   $package"
    
    # Validate
    validate_package "$package" || return 1
    
    # Backup existing
    backup_existing "$app_name"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    # Extract
    extract_package "$package" "$temp_dir"
    
    # Find actual content directory
    local content_dir="$temp_dir"
    local subdirs=($(find "$temp_dir" -maxdepth 1 -type d | tail -n +2))
    if [[ ${#subdirs[@]} -eq 1 ]]; then
        content_dir="${subdirs[0]}"
    fi
    
    # Pre-deploy checks
    run_pre_deploy_checks "$content_dir" || return 1
    
    # Install dependencies
    install_dependencies "$content_dir"
    
    # Deploy
    mkdir -p "$DEPLOY_DIR"
    local target="$DEPLOY_DIR/$app_name"
    
    log "Installing to $target..."
    rm -rf "$target"
    mv "$content_dir" "$target"
    
    # Set permissions
    chmod -R 755 "$target"
    
    # Run post-deploy script
    if [[ -f "$target/post_deploy.sh" ]]; then
        log "Running post-deploy script..."
        cd "$target"
        bash post_deploy.sh || log "WARNING: Post-deploy script had issues"
    fi
    
    log "✓ Deployment complete: $app_name"
    log "Location: $target"
    
    return 0
}

rollback() {
    local app_name=$1
    
    log "Rolling back: $app_name"
    
    # Find latest backup
    local backup=$(find "$BACKUP_DIR" -name "${app_name}_*.tar.gz" | sort -r | head -1)
    
    if [[ -z "$backup" ]]; then
        log "ERROR: No backup found for $app_name"
        return 1
    fi
    
    log "Restoring from: $backup"
    
    local target="$DEPLOY_DIR/$app_name"
    rm -rf "$target"
    
    tar -xzf "$backup" -C "$DEPLOY_DIR"
    
    log "✓ Rollback complete"
}

list_deployments() {
    echo ""
    echo "Deployed Applications:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$DEPLOY_DIR" ]]; then
        echo "  (none)"
        return
    fi
    
    for app in "$DEPLOY_DIR"/*; do
        if [[ -d "$app" ]]; then
            local name=$(basename "$app")
            local size=$(du -sh "$app" 2>/dev/null | cut -f1)
            local date=$(stat -c %y "$app" 2>/dev/null | cut -d' ' -f1)
            printf "  %-20s %8s   %s\n" "$name" "$size" "$date"
        fi
    done
}

main() {
    print_header
    
    case "${1:-help}" in
        deploy)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 deploy <package.tar.gz> [app_name]"
                exit 1
            fi
            deploy_package "$2" "${3:-}"
            ;;
        rollback)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 rollback <app_name>"
                exit 1
            fi
            rollback "$2"
            ;;
        list)
            list_deployments
            ;;
        *)
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  deploy <package> [name]  - Deploy package"
            echo "  rollback <name>          - Rollback to previous version"
            echo "  list                     - List deployed applications"
            echo ""
            echo "Environment Variables:"
            echo "  DEPLOY_DIR  - Deployment directory (default: /opt/deployed_apps)"
            echo "  BACKUP_DIR  - Backup directory (default: /var/backups/deployments)"
            ;;
    esac
}

main "$@"
