# Scanwise

[![Test](https://github.com/VIDADv1/scanwise/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/VIDADv1/scanwise/actions/workflows/test.yml?query=branch%3Amain)
[![Codacy](https://github.com/VIDADv1/scanwise/actions/workflows/codacy.yml/badge.svg?branch=main)](https://github.com/VIDADv1/scanwise/actions/workflows/codacy.yml?query=branch%3Amain)
![GitHub License](https://img.shields.io/github/license/VIDADv1/scanwise)
![GitHub Release](https://img.shields.io/github/v/release/VIDADv1/scanwise)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Scanwise-brightgreen?logo=github)](https://github.com/marketplace/actions/scanwise)


Scanwise is a GitHub Action for running SonarQube scans and generating rich multi-format reports — without needing a hosted SonarQube server.  

Enhanced fork of [gitricko/sonarless](https://github.com/gitricko/sonarless) with improved reporting, configurability, and PR integration.

## 🚀 What's New in Scanwise

- 📊 Multi-format reports (HTML, Markdown, JSON, PDF)
- 🧠 PR and branch-level new code analysis (works with Community Edition)
- ⚙️ Pre-scan scripting and custom scanner options
- 💬 Analysis summaries with PR comments integration

👉 See [Releases](https://github.com/VIDADv1/scanwise/releases) for full changelog.

## ⚙️ Setup & Usage

### Local Development

```bash
# Install the enhanced CLI
curl -s "https://raw.githubusercontent.com/VIDADv1/scanwise/main/install.sh" | bash
```

### GitHub Actions

```yaml
- name: Scanwise Scan
  uses: VIDADv1/scanwise@v1
  with:
    sonar-source-path: 'src'
    sonar-project-name: 'my-project'
    reports-scopes: '["overall", "new"]'
    reports-extensions: '["html", "md", "json"]'
    reports-retention-days: '7'
    new-code-n-days: '3d'
```

## 🔧 Configuration Options

<details open>
<summary><i>Show</i></summary>

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `sonar-project-name` | SonarQube Project Name | Repository name | No |
| `sonar-project-key` | SonarQube Project Key | Repository name | No |
| `sonar-source-path` | Source path from git root | `.` | No |
| `sonar-metrics-path` | Path to metrics JSON | `./sonar-metrics.json` | No |
| `sonar-instance-port` | SonarQube instance port | `9234` | No |
| `sonar-options` | Additional SonarQube scanner options | - | No |
| `pre-scan-script` | Path to pre-scan script or inline script | - | No |
| `generate-pr-comment` | Enable PR comments | `false` | No |
| `new-code-n-days` | New code period (e.g., '3d', '1w') | `30d` | No |
| `reports-scopes` | Report scopes (overall, new) | `[]` | No |
| `reports-extensions` | Report formats (md, html, json, pdf) | `["html"]` | No |
| `reports-retention-days` | Days to keep reports in artifacts | `0` | No |

</details>

## 📚 Usage Examples

### Basic Usage

```yaml
- uses: VIDADv1/scanwise@v1
  with:
    sonar-source-path: 'src'
    sonar-project-name: 'my-project'
```

### With Custom Reports

```yaml
- uses: VIDADv1/scanwise@v1
  with:
    sonar-source-path: 'packages/frontend'
    sonar-project-name: 'frontend'
    reports-scopes: '["overall", "new"]'
    reports-extensions: '["html", "md"]'
    reports-retention-days: '14'
```

#### Summary / PR comment example
<blockquote>
<details>
<summary><i>Show</i></summary>

# 🌟 **Scanwise Analysis Summary for scanwise** 🌟

## 🆕 New code statistics 🆕

### Key values
- **💡 Code Smells:** 6
- **🐞 Bugs:** 3
- **🔒 Vulnerabilities:** 1
- **🔥 Security Hotspots:** 3

### Issues and Security Hotspots Reports
[Click here to download the reports]()

## 🔁 Overall code statistics 🔁

### Key values
- **📊 Lines of Code (LoC):** 38
- **💡 Code Smells:** 6
- **🐞 Bugs:** 3
- **🔒 Vulnerabilities:** 1
- **🔥 Security Hotspots:** 3

### Ratings
- **💎 Maintainability:** ★★★★★
- **⚙️ Reliability:** ★☆☆☆☆
- **🔐 Security:** ★☆☆☆☆
- **🛡 Test Coverage:** 0.00%
- **🌀 Duplicated Lines Density:** 0.0%

### Quality Gate
- **Status:** ✅ **PASSED**

### Issues and Security Hotspots Reports
[Click here to download the reports]()
</details>
</blockquote>

#### Issues Report example
<blockquote>
<details>
<summary><i>Show</i></summary>

### 🌟 **Scanwise overall Issues Details for scanwise** 🌟

| Type | Severity | File | Line | Effort | Author | Rule | Message |
|------|----------|------|------|--------|--------|------|---------|
| BUG | BLOCKER | integration-test/src/main/java/com/example/BadCodeExample.java | 45 | 5min | test@example.com | java:S2095 | Use try-with-resources or close this "FileWriter" in a "finally" clause. |
| VULNERABILITY | BLOCKER | integration-test/src/main/java/com/example/BadCodeExample.java | 29 | 1h | test@example.com | java:S6437 | Revoke and change this password, as it is compromised. |
| BUG | BLOCKER | integration-test/src/main/java/com/example/BadCodeExample.java | 29 | 5min | test@example.com | java:S2095 | Use try-with-resources or close this "Connection" in a "finally" clause. |
| BUG | BLOCKER | integration-test/src/main/java/com/example/BadCodeExample.java | 30 | 5min | test@example.com | java:S2095 | Use try-with-resources or close this "Statement" in a "finally" clause. |
| CODE_SMELL | MAJOR | integration-test/src/main/java/com/example/BadCodeExample.java | 20 | 5min | test@example.com | java:S1068 | Remove this unused "unused" private field. |
| CODE_SMELL | MAJOR | integration-test/src/main/java/com/example/BadCodeExample.java | 23 | 10min | test@example.com | java:S106 | Replace this use of System.out by a logger. |
| CODE_SMELL | MAJOR | integration-test/src/main/java/com/example/BadCodeExample.java | 34 | 10min | test@example.com | java:S106 | Replace this use of System.out by a logger. |
| CODE_SMELL | MINOR | integration-test/src/main/java/com/example/BadCodeExample.java | 10 | 1min | test@example.com | java:S1128 | Remove this unused import 'java.util.ArrayList'. |
| CODE_SMELL | MINOR | integration-test/src/main/java/com/example/BadCodeExample.java | 11 | 1min | test@example.com | java:S1128 | Remove this unused import 'java.util.List'. |
| CODE_SMELL | MINOR | integration-test/src/main/java/com/example/BadCodeExample.java | 9 | 1min | test@example.com | java:S1128 | Remove this unused import 'java.text.SimpleDateFormat'. |
</details>
</blockquote>

#### Hotspots Report example
<blockquote>
<details>
<summary><i>Show</i></summary>

### 🌟 **Scanwise overall security hotspots to review for scanwise** 🌟
| Category | Vuln. Probability | File | Line | Author | Rule | Message |
|----------|-------------------|------|------|--------|------|---------|
| auth | HIGH | integration-test/src/main/java/com/example/BadCodeExample.java | 17 | test@example.com | java:S2068 | 'PASSWORD' detected in this expression, review this potentially hard-coded password. |
| sql-injection | HIGH | integration-test/src/main/java/com/example/BadCodeExample.java | 31 | test@example.com | java:S2077 | Make sure using a dynamically formatted SQL query is safe here. |
| insecure-conf | LOW | integration-test/src/main/java/com/example/BadCodeExample.java | 39 | test@example.com | java:S4507 | Make sure this debug feature is deactivated before delivering the code in production. |
</details>
</blockquote>

### With Pre-scan Script

```yaml
- uses: VIDADv1/scanwise@v1
  with:
    sonar-project-name: 'backend'
    pre-scan-script: |
      echo "Running pre-scan setup..."
      # Add your custom setup commands here
```

## 🤝 Contributing

Contributions are welcome!

If you have ideas for improvements, bug fixes, or new features:
- Fork the repository
- Create a feature branch
- Submit a pull request

Please make sure your code is clean and tested. Feel free to open an issue to discuss major changes before implementing them.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- 🛠️ [gitricko/sonarless](https://github.com/gitricko/sonarless) – Original GitHub Action this project is based on.
- 📄 [baileyjm02/markdown-to-pdf](https://github.com/baileyjm02/markdown-to-pdf) – Converts Markdown reports to HTML and PDF.
- 💬 [peter-evans/create-or-update-comment](https://github.com/peter-evans/create-or-update-comment) and [find-comment](https://github.com/peter-evans/find-comment) – Used to manage GitHub PR comments with analysis summaries.
- 📚 [SonarQube Web API](https://next.sonarqube.com/sonarqube/web_api) – Used for fetching issues, metrics, and hotspots.