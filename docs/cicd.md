# CI/CD Automation Guide

This project uses GitHub Actions to automate software releases and package deployments whenever you tag a new version.

---

### What the Pipeline Does

When you push a tag (e.g. `v0.1.9`):

1. **Builds the APT Package:** Bundles all code scripts, configuration targets, and the CLI wrapper into a standard `.deb` file.
2. **Generates Repository Indexes:** Runs index creation scripts to generate the metadata files (`Packages`, `Packages.gz`, and `Release`).
3. **Cryptographically Signs the Release:** Signs the metadata with a secure GPG key, producing the signed `InRelease` verification indexes.
4. **Deploys to GitHub Pages:** Publishes all the compiled repository assets to the `gh-pages` branch.
5. **Updates the Homebrew Tap:** Automatically clones your external `homebrew-tap` repository, computes the checksum of the source archive, and updates the version and hash inside the formula file.

---

### Why We Use It

* **No Manual Work:** You only need to push a git tag to publish both APT and Homebrew updates.
* **Integrity & Security:** Every package is cryptographically signed, ensuring clients can safely download updates without tampering.
* **Speed:** Hosting packages on GitHub Pages and Tap repositories guarantees fast downloads and zero maintenance costs.
* **Consistency:** Prevents human error in release packaging, version numbering, or checksum calculations.
