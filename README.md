# RESTler API Coverage Testing

Automated setup script for testing the PHP Gaming Website API using Microsoft RESTler fuzzer.

## Description

This repository provides an automated setup script that:

- Clones and builds the RESTler fuzzer
- Starts the PHP Gaming Website in Docker
- Configures and runs RESTler testing against the gaming API
- Copies test results for analysis

## Prerequisites

- **Git** - for cloning repositories
- **Docker** - for running containers
- **curl** - for testing connectivity (usually pre-installed)

## How to Run

### Quick Start

1. **Clone this repository:**

   ```bash
   git clone git@github.com:eoanodea/green-autoscalers-application-coverage.git
   cd green-autoscalers-application-coverage
   ```

2. **Run the full setup:**

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Get your session cookie when prompted:**

   - When you see the prompt to get your session cookie, follow these steps:
   - Open http://localhost:80 in browser
   - Sign up/login to create an account
   - Copy PHPSESSID from Developer Tools > Application > Cookies
   - Update the session ID in your configuration files (`data/restler_settings.json`, `data/custom_dict.json` and `data/restler_auth_config.json`)
   - Press Enter to continue

4. **View results:**
   Results will be available in the `data/restler_working_dir` directory after completion.

### Command Options

```bash
# Show help
./setup.sh --help

# Skip building Docker image (if already built)
./setup.sh --skip-build

# Skip starting website (if already running)
./setup.sh --skip-website

# Only run RESTler test (everything else already setup)
./setup.sh --test-only

# Show session setup instructions
./setup.sh --session-help

# Cleanup all services
./setup.sh --cleanup
```

## Configuration Files

- **`data/openapi.yaml`** - Your API specification
- **`data/restler_settings.json`** - RESTler configuration with session cookie
- **`data/custom_dict.json`** - Custom fuzzing dictionary

## Cleanup

The cleanup option stops all running Docker containers and services:

```bash
./setup.sh --cleanup
```

This stops all Docker containers and services.

## Results

RESTler generates several types of output:

- **Coverage reports** - Which endpoints were successfully tested
- **Security findings** - Potential vulnerabilities discovered
- **Error logs** - Failed requests and reasons
- **Network logs** - All HTTP requests/responses

Results are copied to the `data/` directory for analysis.
