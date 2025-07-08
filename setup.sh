#!/bin/bash

# RESTler Gaming Website Testing Setup Script
# This script automates the setup of RESTler for testing the PHP Gaming Website

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists git; then
        print_error "Git is not installed. Please install Git first."
        echo "macOS: brew install git"
        echo "Ubuntu: sudo apt-get install git"
        exit 1
    fi
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "All prerequisites are installed and running"
}

# Clone repositories
setup_repositories() {
    print_status "Setting up repositories..."
    
    if [ ! -d "restler-fuzzer" ]; then
        print_status "Cloning RESTler repository..."
        git clone https://github.com/microsoft/restler-fuzzer.git
    else
        print_warning "RESTler repository already exists, skipping clone"
    fi
    
    if [ ! -d "php-gaming-website" ]; then
        print_status "Cloning PHP Gaming Website repository..."
        git clone https://github.com/marein/php-gaming-website.git
    else
        print_warning "PHP Gaming Website repository already exists, skipping clone"
    fi
    
    print_success "Repositories setup complete"
}

# Build RESTler Docker image
build_restler() {
    print_status "Building RESTler Docker image..."
    
    cd restler-fuzzer
    docker build --no-cache -t restler .
    cd ..
    
    print_success "RESTler Docker image built successfully"
}

# Start Gaming Website
start_gaming_website() {
    print_status "Starting PHP Gaming Website..."
    
    docker compose -f php-gaming-website/deploy/single-server/docker-compose.yml up -d
    
    # Wait for the website to be ready
    print_status "Waiting for website to be ready..."
    sleep 10
    
    # Check if website is accessible
    for i in {1..30}; do
        if curl -s http://localhost:80 >/dev/null 2>&1; then
            print_success "Gaming website is running and accessible at http://localhost:80"
            return 0
        fi
        print_status "Waiting for website... (attempt $i/30)"
        sleep 2
    done
    
    print_error "Website failed to start properly"
    exit 1
}

# Run RESTler test
run_restler_test() {
    print_status "Running RESTler test..."
    
    if [ ! -f "data/openapi.yaml" ]; then
        print_error "OpenAPI specification file not found at data/openapi.yaml"
        print_warning "Please ensure your OpenAPI spec is available at this location"
        exit 1
    fi
    
    if [ ! -f "data/restler_settings.json" ]; then
        print_error "RESTler settings file not found at data/restler_settings.json"
        print_warning "Please ensure your RESTler configuration files are available"
        exit 1
    fi
    
    print_status "Starting RESTler fuzzing session..."
    print_warning "Make sure you have updated the PHPSESSID in your configuration files!"
    
    docker run -it --rm \
        -v $(pwd)/data:/data \
        --network host \
        restler \
        sh -c "
        python3 /data/restler-quick-start.py \
            --api_spec_path /data/openapi.yaml \
            --restler_drop_dir /RESTler \
            --ip localhost \
            --port 80 && \
        echo 'RESTler completed, copying results...' && \
        cp -r /restler_working_dir/ /data/ 2>/dev/null || \
        "
    
    print_success "RESTler test completed"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    docker compose -f php-gaming-website/deploy/single-server/docker-compose.yml down --remove-orphans >/dev/null 2>&1 || true
}

# Show manual session setup instructions
show_session_setup() {
    print_status "Session Setup Instructions:"
    echo ""
    echo "1. Open http://localhost:80 in your browser"
    echo "2. Sign up for a new account or log in"
    echo "3. Open Developer Tools (F12) > Application > Cookies > localhost"
    echo "4. Copy the PHPSESSID value"
    echo "5. Update your configuration files:"
    echo "   - data/restler_settings.json"
    echo "   - data/custom_dict.json"
    echo "6. Replace 'PLACEHOLDER_SESSION_ID' with your actual PHPSESSID"
    echo ""
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h        Show this help message"
    echo "  --skip-build      Skip building RESTler Docker image"
    echo "  --skip-website    Skip starting the gaming website"
    echo "  --test-only       Only run RESTler test (assume everything else is setup)"
    echo "  --cleanup         Cleanup and stop all services"
    echo "  --session-help    Show instructions for manual session setup"
    echo ""
}

# Main function
main() {
    local skip_build=false
    local skip_website=false
    local test_only=false
    local cleanup_only=false
    local session_help=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            --skip-build)
                skip_build=true
                shift
                ;;
            --skip-website)
                skip_website=true
                shift
                ;;
            --test-only)
                test_only=true
                shift
                ;;
            --cleanup)
                cleanup_only=true
                shift
                ;;
            --session-help)
                session_help=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Handle cleanup
    if [ "$cleanup_only" = true ]; then
        cleanup
        print_success "Cleanup completed"
        exit 0
    fi
    
    # Show session help
    if [ "$session_help" = true ]; then
        show_session_setup
        exit 0
    fi
    
    # Set up trap for cleanup on exit
    trap cleanup EXIT
    
    print_status "Starting RESTler Gaming Website Testing Setup"
    
    if [ "$test_only" = false ]; then
        check_prerequisites
        setup_repositories
        
        if [ "$skip_build" = false ]; then
            build_restler
        fi
        
        if [ "$skip_website" = false ]; then
            start_gaming_website
            echo ""
            show_session_setup
            echo ""
            print_warning "Please update your PHPSESSID in the configuration files before continuing."
            read -p "Press Enter to continue when ready..."
        fi
    fi
    
    run_restler_test
    
    print_success "Setup and testing completed successfully!"
    print_status "Results are available in: data/"
    print_warning "Remember to run '$0 --cleanup' when you're done to stop all services"
}

# Run main function with all arguments
main "$@"