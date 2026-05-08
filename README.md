# macOS Data Science Setup

Automated setup for a complete data science development environment on macOS using Homebrew and Conda.

## Goals

- **Reproducible environment**: Complete setup from a fresh macOS install
- **Idempotent**: Safe to run multiple times, updates existing installations
- **Self-documenting**: Clear terminal output shows what's happening
- **Minimal manual steps**: One command to set up everything

## What Gets Installed

### System Tools (via Homebrew)

- Package managers: Homebrew, mas (Mac App Store CLI)
- Development tools: git, gh, wget, pandoc, typst
- Python tooling: uv (package installer)
- Utilities: fd, ripgrep, jq, yq, gnupg

### Applications (via Brewfile)

- Development: VS Code, iTerm2, GitHub Desktop, Docker Desktop
- LaTeX: MacTeX, IguanaTeX for PowerPoint
- Productivity: ChatGPT, Claude, Proton Drive, Proton VPN
- Research: Zotero, NetLogo, Safe Exam Browser
- Communication: Zoom, Spotify, Google Chrome

### Fonts

- Fira Code (monospace with ligatures)
- Fira Sans

### Miniforge (conda/mamba)

- Installed following the [recommended method](https://github.com/conda-forge/miniforge)
- Automatically initializes conda/mamba for zsh during installation
- Provides conda and mamba package managers for Python environments
- Configured with conda-forge as the default channel

### Python Environment

- Python 3.13 with data science stack from `environment.yml`
- Packages: numpy, pandas, matplotlib, seaborn, scipy, scikit-learn
- ML/Stats: pytorch, botorch, ax-platform, pymc, statsmodels
- Simulation: salabim, statannotations
- Development: jupyter, black, black-jupyter

## Usage

### Complete Setup

Run everything in sequence:

```bash
make all
```

### Individual Steps

Run specific parts as needed:

```bash
make homebrew    # Install Xcode tools and Homebrew
make bundle      # Install Brewfile packages
make miniforge   # Install Miniforge (conda/mamba)
make conda       # Initialize Conda/Mamba and setup Python environment
make latex-perl  # (Optional) Install Perl modules for latexindent
make update      # Update all installed components
```

### Keeping Your System Updated

Keep all components up-to-date:

```bash
make update
```

This will:
- Update Homebrew itself
- Upgrade all Homebrew packages
- Upgrade all Homebrew casks (requires `brew-cu`)
- Update conda and mamba in base environment
- Update your Python environment from `environment.yml`
- Clean package caches

## Configuration Files

- **`Makefile`**: Orchestrates the setup process
- **`Brewfile`**: Defines all Homebrew packages, casks, and fonts
- **`environment.yml`**: Specifies Python environment and dependencies

## Requirements

- macOS (tested on Apple Silicon)
- Internet connection
- Administrator access (for initial Homebrew installation)

## Customization

1. Edit `Brewfile` to add/remove packages and applications
2. Edit `Makefile` MINIFORGE_PREFIX constant to change installation location (default: `~/miniforge3`)
3. Edit `environment.yml` to modify Python packages
4. Adjust other constants at the top of `Makefile` if needed

## Notes

### General

- First run requires interaction for Xcode Command Line Tools installation
- Applications install to `~/Applications` by default
- Miniforge installs to `~/miniforge3` by default (configurable via MINIFORGE_PREFIX in Makefile)
- Shell configuration is added to `~/.zprofile` and `~/.zshenv`
- Conda is configured to not auto-activate the base environment

### LaTeX Code Formatting in VS Code

**Solution**: The LaTeX Workshop extension requires Perl modules for `latexindent` to format code. After installing MacTeX, run:

```bash
make latex-perl
```

This installs the required Perl modules (File::HomeDir, YAML::Tiny, Unicode::GCString) system-wide.

**Note**: Modules must be installed with `sudo cpan` to be accessible to system-installed tools like `latexindent`.

## Further Tools to Explore

### Node.js and pnpm

See https://nodejs.org/en/download

```
# Download and install Node.js:
brew install node@24

# Verify the Node.js version:
node -v # Should print "v24.11.0".

# Download and install pnpm:
corepack enable pnpm

# Verify pnpm version:
pnpm -v
```

Caveats:

```
node@24 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have node@24 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/node@24/bin:$PATH"' >> ~/.zshrc

For compilers to find node@24 you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/node@24/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/node@24/include"
```

### Mac App Store CLI (`mas`)

Install Mac App Store apps via command line:

```bash
mas list                    # List installed apps
mas "Xcode", id: 497799835  # Add to Brewfile
```

### Homebrew Graph

Visualize dependencies of installed formulae:

- Repository: https://github.com/martido/homebrew-graph

### Chezmoi - Dotfiles Manager

Manage dotfiles across machines:

- Website: https://chezmoi.io/
- Install: `brew install chezmoi`
- Quick start: https://chezmoi.io/quick-start/

## Known Issues

## Uninstalling Casks

Uninstalling cask applications with all associated files:

```bash
brew uninstall [app] --cask --zap --force
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
