# DevForge Developer & Contributor Guide

Welcome to the DevForge contributor guidelines. This document outlines the standards and workflows required to contribute, test, and release patches.

---

### Pull Request Guidelines

Before submitting a Pull Request, please follow these steps to keep the codebase clean, robust, and consistent:

1. **Create a Feature Branch:**
   Branch off from `main` using a descriptive name:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```
2. **Keep Code Clean:**
   * Write clean, readable bash code.
   * Keep inline comments sparse and meaningful. Avoid obvious or verbose explanatory comments.
   * Adhere to strict scripting standards (`set -euo pipefail`).
3. **Run Static Checks & Tests:**
   Verify that scripts do not introduce shellcheck violations or break bats unit tests:
   ```bash
   dforge test
   ```
4. **Clean Git History:**
   * Commit messages should be clear and concise.
   * Rebase on `main` to resolve conflicts before pushing.

---

### Release Management Cheat Sheet

We automate releases via GitHub Actions. Creating a new patch release involves tagging the main branch with the correct semantic version.

Use these commands to tag and release a patch:

```bash
# 1. Pull the latest commits
git checkout main
git pull origin main

# 2. Create an annotated git tag (increment the patch number)
# Format: v<major>.<minor>.<patch>
git tag -a v0.1.10 -m "Release v0.1.10"

# 3. Push the tag to GitHub
git push origin v0.1.10
```

Once pushed, the CI/CD pipeline will automatically:
1. Update and compile the Debian APT repository packages on `gh-pages`.
2. Push version updates and SHA256 checksums to the `homebrew-tap` repository.
