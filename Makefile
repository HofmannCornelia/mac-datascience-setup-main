# mac-datascience-setup/Makefile
# Automated macOS data science development environment setup
#
# This Makefile orchestrates the complete setup of a data science environment on macOS:
#   - Installs Xcode Command Line Tools and Homebrew package manager
#   - Installs all packages, applications, and fonts from Brewfile
#   - Installs Miniforge (conda/mamba) following the recommended method
#   - Configures Conda/Mamba and creates Python environment from environment.yml
#
# Usage:
#   make all       - Run complete setup (homebrew → bundle → miniforge → conda)
#   make homebrew  - Install and configure Homebrew only
#   make bundle    - Install Brewfile packages only
#   make miniforge - Install Miniforge (conda/mamba) only
#   make conda     - Initialize Conda/Mamba and setup Python environment
#   make latex-perl - Install Perl modules for latexindent (optional)
#   make update    - Update all installed components (Homebrew, Conda, environments)
#
# All targets are idempotent and can be run multiple times safely.

# Configuration
BREWFILE := Brewfile
BREW := /opt/homebrew/bin/brew
CONDA_ENV_FILE := environment.yml
DEFAULT_CONDA_ENV_NAME := default
MINIFORGE_PREFIX := $(HOME)/miniforge3

.PHONY: all homebrew bundle miniforge conda latex-perl update

# --- Main target: Complete setup ---
all: homebrew bundle miniforge conda
	@echo ""
	@echo "=========================================="
	@echo "✅ Complete setup finished successfully!"
	@echo "=========================================="
	@echo ""
	@echo "ℹ️  Optional: Run 'make latex-perl' to install Perl modules for latexindent"
	@echo "ℹ️  Keep updated: Run 'make update' to update all components"
	@echo ""

# --- Step 1: Homebrew installation and configuration ---
# Installs Xcode Command Line Tools (prerequisite for Homebrew)
# Installs Homebrew package manager with proper permissions
# Configures shell environment in ~/.zprofile and cask options in ~/.zshenv
# Idempotent: Safe to run multiple times, skips if already configured
homebrew:
	@echo "=========================================="
	@echo "==> Step 1: Homebrew Setup"
	@echo "=========================================="
	@echo ""
	@echo "Checking Xcode Command Line Tools..."
	@if ! xcode-select -p >/dev/null 2>&1; then \
		echo "  ⬇️  Installing Xcode Command Line Tools..."; \
		xcode-select --install; \
		echo ""; \
		echo "  ⚠️  Please complete the installation in the dialog that appeared,"; \
		echo "      then run 'make homebrew' again to continue."; \
		echo ""; \
		exit 1; \
	else \
		echo "  ✅ Xcode Command Line Tools are installed"; \
	fi
	@echo ""
	@echo "Checking Homebrew installation..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "  ⬇️  Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo ""; \
		echo "  Setting up permissions..."; \
		sudo chown -R $$USER $$($(BREW) --prefix)/* || true; \
		chmod u+w $$($(BREW) --prefix)/* || true; \
		echo "  ✅ Homebrew installed successfully"; \
	else \
		echo "  ✅ Homebrew is already installed"; \
	fi
	@echo ""
	@echo "Configuring shell environment..."
	@eval "$$($(BREW) shellenv)" || true
	@if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then \
		echo "  Adding Homebrew to ~/.zprofile..."; \
		echo '' >> ~/.zprofile; \
		echo '# Homebrew' >> ~/.zprofile; \
		echo 'eval "$$($(BREW) shellenv)"' >> ~/.zprofile; \
		echo "  ✅ Homebrew path configured in ~/.zprofile"; \
	else \
		echo "  ✅ Homebrew already configured in ~/.zprofile"; \
	fi
	@if ! grep -q 'HOMEBREW_CASK_OPTS' ~/.zshenv 2>/dev/null; then \
		echo "  Configuring cask installation directory..."; \
		echo 'export HOMEBREW_CASK_OPTS="--appdir=$$HOME/Applications"' >> ~/.zshenv; \
		echo "  ✅ Cask apps will install to ~/Applications"; \
	else \
		echo "  ✅ Cask options already configured in ~/.zshenv"; \
	fi
	@echo ""
	@echo "🍺 Homebrew setup complete!"
	@echo ""

# --- Step 2: Brewfile bundle installation ---
# Installs all packages, applications, and fonts defined in $(BREWFILE)
# Sources ~/.zshenv to respect HOMEBREW_CASK_OPTS for application directory
# Idempotent: Safe to run multiple times, installs only missing packages
bundle: homebrew
	@echo "=========================================="
	@echo "==> Step 2: Brewfile Bundle Installation"
	@echo "=========================================="
	@echo ""
	@echo "Installing packages from $(BREWFILE)..."
	@source ~/.zshenv 2>/dev/null || true && \
		eval "$$($(BREW) shellenv)" && \
		brew bundle --file=$(BREWFILE)
	@echo ""
	@echo "✅ All Brewfile packages installed!"
	@echo ""

# --- Step 3: Miniforge installation ---
# Installs Miniforge following the recommended method from conda-forge/miniforge repository
# Downloads the installer script for the current OS and architecture
# Runs installer in batch mode with -c flag to initialize conda for zsh
# Sets up conda/mamba commands in ~/.zshrc automatically
# Idempotent: Safe to run multiple times, skips if already installed
miniforge:
	@echo "=========================================="
	@echo "==> Step 3: Miniforge Installation"
	@echo "=========================================="
	@echo ""
	@echo "Checking Miniforge installation..."
	@if [ -d "$(MINIFORGE_PREFIX)" ] && [ -x "$(MINIFORGE_PREFIX)/bin/conda" ]; then \
		echo "  ✅ Miniforge is already installed at $(MINIFORGE_PREFIX)"; \
		echo ""; \
		echo "ℹ️  To reinstall, first remove the existing installation:"; \
		echo "   rm -rf $(MINIFORGE_PREFIX)"; \
		echo ""; \
	else \
		echo "  Miniforge not found at $(MINIFORGE_PREFIX)"; \
		echo ""; \
		echo "Detecting system architecture..."; \
		INSTALLER_NAME="Miniforge3-$$(uname)-$$(uname -m).sh"; \
		DOWNLOAD_URL="https://github.com/conda-forge/miniforge/releases/latest/download/$$INSTALLER_NAME"; \
		echo "  OS: $$(uname)"; \
		echo "  Architecture: $$(uname -m)"; \
		echo "  Installer: $$INSTALLER_NAME"; \
		echo ""; \
		echo "⬇️  Downloading Miniforge installer..."; \
		if curl -L -O "$$DOWNLOAD_URL"; then \
			echo "  ✅ Download complete"; \
		else \
			echo "  ❌ Failed to download installer"; \
			echo ""; \
			exit 1; \
		fi; \
		echo ""; \
		echo "Installing Miniforge to $(MINIFORGE_PREFIX)..."; \
		if bash "$$INSTALLER_NAME" -b -c -p "$(MINIFORGE_PREFIX)"; then \
			echo "  ✅ Miniforge installed successfully"; \
			echo ""; \
			echo "Activating conda for current session..."; \
			eval "$$($(MINIFORGE_PREFIX)/bin/conda shell.zsh hook 2>/dev/null)"; \
			echo "  ✅ Conda activated"; \
		else \
			echo "  ❌ Installation failed"; \
			echo ""; \
			rm -f "$$INSTALLER_NAME"; \
			exit 1; \
		fi; \
		echo ""; \
		echo "Cleaning up installer..."; \
		rm -f "$$INSTALLER_NAME"; \
		echo "  ✅ Installer removed"; \
		echo ""; \
		echo "🐍 Miniforge installation complete!"; \
		echo ""; \
		echo "   Installation directory: $(MINIFORGE_PREFIX)"; \
		echo "   Conda command: $(MINIFORGE_PREFIX)/bin/conda"; \
		echo "   Mamba command: $(MINIFORGE_PREFIX)/bin/mamba"; \
		echo ""; \
		echo "ℹ️  Conda has been initialized for your shell"; \
		echo "   Restart your shell or run: source ~/.zshrc"; \
		echo ""; \
	fi

# --- Step 4: Conda/Mamba initialization and Python environment setup ---
# Initializes conda/mamba shell integration and manages Python environments
# Creates or updates Python environment from $(CONDA_ENV_FILE) specification
# Steps:
#   1. Verify conda is installed
#   2. Initialize conda for zsh (which also enables mamba)
#   3. Configure conda to not auto-activate base environment
#   4. Verify mamba is available
#   5. Parse environment name from $(CONDA_ENV_FILE) or use $(DEFAULT_CONDA_ENV_NAME)
#   6. Create new environment or update existing one (with --prune flag)
#   7. Clean package cache to reclaim disk space
# Note: Conda initialization modifies ~/.zshrc to enable conda/mamba at shell startup
# Idempotent: Safe to run multiple times, updates environment if it exists
conda:
	@echo "=========================================="
	@echo "==> Step 4: Conda Python Environment Setup"
	@echo "=========================================="
	@echo ""
	@echo "Verifying Conda installation..."
	@if ! command -v conda >/dev/null 2>&1; then \
		if [ -x "$(MINIFORGE_PREFIX)/bin/conda" ]; then \
			echo "  ℹ️  Conda installed but not in current shell session"; \
			echo "  Loading: $(MINIFORGE_PREFIX)/bin/conda"; \
			echo ""; \
			eval "$$($(MINIFORGE_PREFIX)/bin/conda shell.zsh hook 2>/dev/null)"; \
		else \
			echo "  ❌ Conda is not installed"; \
			echo ""; \
			echo "  Conda is required for Python environment management."; \
			echo "  Install Miniforge using the recommended method:"; \
			echo ""; \
			echo "    make miniforge"; \
			echo ""; \
			echo "  Then run 'make conda' again."; \
			echo ""; \
			exit 1; \
		fi; \
	fi
	@echo "  ✅ Conda is installed"
	@echo ""
	@echo "Initializing Conda for zsh shell..."
	@if grep -q 'conda initialize' ~/.zshrc 2>/dev/null; then \
		echo "  ✅ Conda already initialized in ~/.zshrc"; \
	else \
		echo "  Configuring conda shell integration..."; \
		eval "$$(conda shell.zsh hook 2>/dev/null || true)"; \
		if conda init zsh >/dev/null 2>&1; then \
			echo "  ✅ Conda initialized for zsh"; \
			echo "  ℹ️  Changes take effect in new shell sessions"; \
		else \
			echo "  ⚠️  Conda init completed with warnings (continuing)"; \
		fi; \
	fi
	@echo ""
	@echo "Configuring Conda settings..."
	@if conda config --show auto_activate_base 2>/dev/null | grep -q 'True'; then \
		echo "  Setting auto_activate_base=false..."; \
		conda config --set auto_activate_base false 2>/dev/null || true; \
		echo "  ✅ Base environment will not auto-activate"; \
	else \
		echo "  ✅ auto_activate_base already set to false"; \
	fi
	@echo ""
	@echo "Verifying mamba availability..."
	@if command -v mamba >/dev/null 2>&1; then \
		echo "  ✅ Mamba is available (version: $$(mamba --version 2>/dev/null | head -n1))"; \
	else \
		echo "  ⚠️  Mamba command not found in current shell"; \
		echo "     Restart your shell or run: source ~/.zshrc"; \
	fi
	@echo ""
	@if [ ! -f $(CONDA_ENV_FILE) ]; then \
		echo "ℹ️  No $(CONDA_ENV_FILE) found, skipping environment creation"; \
		echo ""; \
		echo "   To create a Python environment:"; \
		echo "   1. Add an $(CONDA_ENV_FILE) file to this directory"; \
		echo "   2. Run 'make conda' again"; \
		echo ""; \
		exit 0; \
	fi
	@echo "Parsing environment configuration..."
	@if command -v yq >/dev/null 2>&1; then \
		ENV_NAME="$$(yq -r '.name // "$(DEFAULT_CONDA_ENV_NAME)"' $(CONDA_ENV_FILE) 2>/dev/null || echo $(DEFAULT_CONDA_ENV_NAME))"; \
	else \
		ENV_NAME="$$(grep '^name:' $(CONDA_ENV_FILE) 2>/dev/null | sed 's/^name:[[:space:]]*//' || echo $(DEFAULT_CONDA_ENV_NAME))"; \
	fi; \
	if [ -z "$$ENV_NAME" ] || [ "$$ENV_NAME" = "null" ]; then \
		ENV_NAME="$(DEFAULT_CONDA_ENV_NAME)"; \
		echo "  ⚠️  No name found in $(CONDA_ENV_FILE), using: $$ENV_NAME"; \
	else \
		echo "  Environment name: $$ENV_NAME"; \
	fi; \
	echo ""; \
	echo "Detecting package manager..."; \
	if command -v mamba >/dev/null 2>&1; then \
		CONDA_CMD=mamba; \
		echo "  ✅ Using mamba (faster package operations)"; \
	else \
		CONDA_CMD=conda; \
		echo "  ✅ Using conda"; \
	fi; \
	echo ""; \
	echo "Checking environment status..."; \
	if $$CONDA_CMD env list 2>/dev/null | awk '{print $$1}' | grep -q "^$$ENV_NAME$$"; then \
		echo "  Found existing environment '$$ENV_NAME'"; \
		echo "  ⬇️  Updating environment..."; \
		if $$CONDA_CMD env update -f $(CONDA_ENV_FILE) -n $$ENV_NAME --yes --prune 2>&1; then \
			echo "  ✅ Environment '$$ENV_NAME' updated successfully"; \
		else \
			echo "  ❌ Failed to update environment '$$ENV_NAME'"; \
			echo ""; \
			exit 1; \
		fi; \
	else \
		echo "  Environment '$$ENV_NAME' not found"; \
		echo "  ⬇️  Creating new environment..."; \
		if $$CONDA_CMD env create -f $(CONDA_ENV_FILE) -n $$ENV_NAME --yes 2>&1; then \
			echo "  ✅ Environment '$$ENV_NAME' created successfully"; \
		else \
			echo "  ❌ Failed to create environment '$$ENV_NAME'"; \
			echo ""; \
			exit 1; \
		fi; \
	fi; \
	echo ""; \
	echo "Cleaning package cache..."; \
	if $$CONDA_CMD clean -yaf >/dev/null 2>&1; then \
		echo "  ✅ Cache cleaned successfully"; \
	else \
		echo "  ⚠️  Cache cleanup completed with warnings"; \
	fi; \
	echo ""; \
	echo "🐍 Python environment ready!"; \
	echo ""; \
	echo "   Activate with: conda activate $$ENV_NAME"; \
	echo ""

# --- Step 4 (Optional): Perl modules for latexindent ---
# Installs Perl modules that enable code formatting with latexindent.
# These modules allow the LaTeX Workshop extension in VS Code to format .tex files.
# Modules are installed system-wide using macOS system Perl (/usr/bin/perl) which
# latexindent is configured to use by default.
# Purpose: Enable latexindent code formatting functionality (included in Brewfile)
# Note: Requires administrator password for sudo cpan installation
latex-perl:
	@echo "=========================================="
	@echo "==> Optional: Perl Modules for latexindent"
	@echo "=========================================="
	@echo ""
	@echo "Installing Perl modules..."
	@echo ""
	@if ! command -v latexindent >/dev/null 2>&1; then \
		echo "  ⚠️  latexindent not found"; \
		echo ""; \
		echo "  These modules are useful when latexindent is installed."; \
		echo "  To install MacTeX (which includes latexindent):"; \
		echo ""; \
		echo "    make bundle"; \
		echo ""; \
		echo "  You can install the modules now or run 'make latex-perl' later."; \
		echo ""; \
		read -p "  Continue installing Perl modules anyway? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "  Cancelled."; \
			echo ""; \
			exit 0; \
		fi; \
	else \
		echo "  ✅ latexindent found: $$(command -v latexindent)"; \
	fi
	@echo ""
	@echo "ℹ️  Installing Perl modules system-wide (requires sudo)"
	@echo "   This allows latexindent to use these modules for code formatting."
	@echo ""
	@echo "Installing File::HomeDir..."
	@sudo cpan -i File::HomeDir
	@echo ""
	@echo "Installing YAML::Tiny..."
	@sudo cpan -i YAML::Tiny
	@echo ""
	@echo "Installing Unicode::GCString..."
	@sudo cpan -i Unicode::GCString
	@echo ""
	@echo "✅ Perl modules installed successfully!"
	@echo ""
	@echo "📝 Perl modules are now available for latexindent"
	@echo "   (LaTeX Workshop extension can now use latexindent for formatting)"
	@echo ""

# --- Update target: Update all installed components ---
# Updates Homebrew packages, casks, Conda/Mamba, and Python environments
# Steps:
#   1. Update Homebrew itself
#   2. Upgrade all Homebrew packages
#   3. Upgrade all Homebrew casks (if brew-cu is available)
#   4. Update conda and mamba in base environment
#   5. Update all conda environments
# Note: Requires Homebrew, Conda/Mamba to be installed
# Idempotent: Safe to run multiple times
update:
	@echo "=========================================="
	@echo "==> Updating All Components"
	@echo "=========================================="
	@echo ""
	@echo "Step 1: Updating Homebrew..."
	@if command -v brew >/dev/null 2>&1; then \
		if brew update; then \
			echo "  ✅ Homebrew updated successfully"; \
		else \
			echo "  ⚠️  Homebrew update completed with warnings"; \
		fi; \
	else \
		echo "  ⚠️  Homebrew not found, skipping"; \
	fi
	@echo ""
	@echo "Step 2: Upgrading Homebrew packages..."
	@if command -v brew >/dev/null 2>&1; then \
		if brew upgrade; then \
			echo "  ✅ Homebrew packages upgraded"; \
		else \
			echo "  ⚠️  No packages to upgrade or upgrade completed with warnings"; \
		fi; \
	else \
		echo "  ⚠️  Homebrew not found, skipping"; \
	fi
	@echo ""
	@echo "Step 3: Upgrading Homebrew casks..."
	@if command -v brew >/dev/null 2>&1; then \
		if brew cu -fa 2>/dev/null; then \
			echo "  ✅ Homebrew casks upgraded"; \
		else \
			echo "  ℹ️  brew-cu not available or no casks to upgrade"; \
			echo "     Install with: brew tap buo/cask-upgrade"; \
		fi; \
	else \
		echo "  ⚠️  Homebrew not found, skipping"; \
	fi
	@echo ""
	@echo "Step 4: Updating Conda and Mamba..."
	@if command -v conda >/dev/null 2>&1; then \
		echo "  Updating conda in base environment..."; \
		if conda update -n base conda --yes 2>&1; then \
			echo "  ✅ Conda updated successfully"; \
		else \
			echo "  ⚠️  Conda update completed with warnings"; \
		fi; \
		echo ""; \
		if command -v mamba >/dev/null 2>&1; then \
			echo "  Updating mamba in base environment..."; \
			if mamba update -n base mamba --yes 2>&1; then \
				echo "  ✅ Mamba updated successfully"; \
			else \
				echo "  ⚠️  Mamba update completed with warnings"; \
			fi; \
		else \
			echo "  ℹ️  Mamba not found, skipping"; \
		fi; \
	else \
		echo "  ⚠️  Conda not found, skipping"; \
		echo "     Install with: make miniforge"; \
	fi
	@echo ""
	@echo "Step 5: Updating Python environments..."
	@if command -v conda >/dev/null 2>&1 && [ -f $(CONDA_ENV_FILE) ]; then \
		if command -v yq >/dev/null 2>&1; then \
			ENV_NAME="$$(yq -r '.name // "$(DEFAULT_CONDA_ENV_NAME)"' $(CONDA_ENV_FILE) 2>/dev/null || echo $(DEFAULT_CONDA_ENV_NAME))"; \
		else \
			ENV_NAME="$$(grep '^name:' $(CONDA_ENV_FILE) 2>/dev/null | sed 's/^name:[[:space:]]*//' || echo $(DEFAULT_CONDA_ENV_NAME))"; \
		fi; \
		if [ -z "$$ENV_NAME" ] || [ "$$ENV_NAME" = "null" ]; then \
			ENV_NAME="$(DEFAULT_CONDA_ENV_NAME)"; \
		fi; \
		if command -v mamba >/dev/null 2>&1; then \
			CONDA_CMD=mamba; \
		else \
			CONDA_CMD=conda; \
		fi; \
		if $$CONDA_CMD env list 2>/dev/null | awk '{print $$1}' | grep -q "^$$ENV_NAME$$"; then \
			echo "  Updating environment '$$ENV_NAME'..."; \
			if $$CONDA_CMD env update -f $(CONDA_ENV_FILE) -n $$ENV_NAME --yes --prune 2>&1; then \
				echo "  ✅ Environment '$$ENV_NAME' updated successfully"; \
			else \
				echo "  ❌ Failed to update environment '$$ENV_NAME'"; \
			fi; \
		else \
			echo "  ℹ️  Environment '$$ENV_NAME' not found, skipping"; \
			echo "     Create with: make conda"; \
		fi; \
		echo ""; \
		echo "Cleaning package cache..."; \
		if $$CONDA_CMD clean -yaf >/dev/null 2>&1; then \
			echo "  ✅ Cache cleaned successfully"; \
		else \
			echo "  ⚠️  Cache cleanup completed with warnings"; \
		fi; \
	else \
		echo "  ℹ️  No $(CONDA_ENV_FILE) found or Conda not installed, skipping"; \
	fi
	@echo ""
	@echo "✅ Update complete!"
	@echo ""
