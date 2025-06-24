# GitHub Actions CI/CD Pipeline

This repository uses GitHub Actions to validate pull requests and deploy documentation.

## Workflows

### PR Validation (`pr-validation.yml`)
Runs on every pull request to validate:
- **Markdown linting** - Ensures consistent formatting
- **MkDocs build** - Verifies site builds successfully  
- **Link checking** - Validates external links
- **Spell checking** - Catches typos and errors
- **YAML validation** - Lints configuration files
- **File validation** - Checks naming conventions
- **Image optimization** - Validates image sizes and alt text

### Content Quality (`content-quality.yml`)
Additional quality checks for:
- **Prose quality** - Writing style and readability
- **Inclusive language** - Ensures accessible content
- **Navigation structure** - Validates all files are properly linked
- **Metadata validation** - Checks for proper headings

### PR Summary (`pr-summary.yml`)
Provides overview of changes and validation status.

### Deployment (`gh-pages-deploy.yml`)
Automatically deploys to GitHub Pages on main branch updates.

## Configuration Files

- `.markdownlint-cli2.yaml` - Markdown linting rules
- `mlc_config.json` - Link checker settings
- `cspell.json` - Spell checker dictionary
- `yamllint.yml` - YAML validation rules