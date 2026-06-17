# Pull Requests

Ready to contribute content to the AWS Networking Best Practices guide? This page walks you through creating a pull request - from making your first changes to getting them merged into the main repository.

## Quick Start

**New to pull requests?** Here's the essential process:

1. **[Fork](#1-fork-the-repository-on-github)** the repository on GitHub

2. **[Create a branch](#2-create-a-branch-for-your-changes)** for your changes

3. **[Make your edits](#3-make-your-edits-and-commit-them)** and commit them

4. **[Submit a pull request](#4-submit-a-pull-request-with-a-clear-description)** with a clear description

5. Follow through with the **[Review Process](#5-review-process)**

**Need more details?** Continue reading for the complete workflow.

## Before You Submit

!!! tip "Checklist"
    * [ ] Changes follow our [conventions](conventions.md)

    * [ ] All links work correctly

    * [ ] Commit messages are descriptive

    * [ ] Referenced any related issues in your PR description

    * [ ] Tested that documentation builds without errors

## Step-by-Step Process

### 1. Fork the repository on GitHub

* Fork the [aws-networking-best-practices] repository on GitHub ([GitHub Docs: Forking a repository][fork-docs]{:target="_blank"})

* Clone your fork to your local machine ([GitHub Docs: Cloning a repository][clone-docs]{:target="_blank"})

* Create a new branch: `git checkout -b your-feature-name` ([GitHub Docs: Git branches][branch-docs]{:target="_blank"})

[aws-networking-best-practices]: https://github.com/aws/aws-networking-best-practices
[fork-docs]: https://docs.github.com/en/get-started/quickstart/fork-a-repo
[clone-docs]: https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository
[branch-docs]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches

### 2. Create a branch for your changes

* Create a new branch: `git checkout -b your-feature-name` ([GitHub Docs: Git branches][branch-docs]{:target="_blank"})

* Keep branch names descriptive: `add-transit-gateway-best-practices` or `fix-vpc-peering-link`

[branch-docs]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches

### 3. Make your edits and commit them

* Edit the documentation files

* Commit changes in logical chunks with clear messages ([GitHub Docs: About commits][commit-docs]{:target="_blank"})

* Push to your fork regularly: `git push origin your-feature-name` ([GitHub Docs: Pushing changes][push-docs]{:target="_blank"})

[commit-docs]: https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/about-commits
[push-docs]: https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository

### 4. Submit a pull request with a clear description

* Open a pull request from your fork to the upstream repository ([GitHub Docs: Creating a PR from a fork][create-pr-fork-docs]{:target="_blank"})

* Include a clear description of your changes

* Reference any related issues or discussions ([GitHub Docs: Linking issues][linking-issues]{:target="_blank"})

* Consider opening a draft pull request early for feedback ([GitHub Docs: Draft PRs][draft-pr-docs]{:target="_blank"})

[create-pr-fork-docs]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork
[draft-pr-docs]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests#draft-pull-requests
[linking-issues]: https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue

### 5. Review Process

* Respond to reviewer feedback promptly ([GitHub Docs: PR reviews][pr-review-docs]{:target="_blank"})

* Make requested changes and push updates

* Your PR will be merged once approved

[pr-review-docs]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews

!!! example "Good Commit Messages"
    * ✅ "Add Transit Gateway best practices for multi-account setups"

    * ✅ "Fix broken link in VPC peering documentation"

    * ❌ "Update docs"

    * ❌ "Various fixes"

## What Happens Next?

After your pull request is merged:

* Your changes will appear in the live documentation

* You can delete your feature branch

* Consider contributing more - we appreciate ongoing contributors!

Thank you for helping improve AWS networking guidance for the community.

## Environment setup

First, clone the repository.

```bash
git clone https://github.com/YOUR-USERNAME/aws-networking-best-practices
cd aws-networking-best-practices
```

Then source the setup script to create a Python virtual environment and install all dependencies:

```bash
source ./scripts/setup.sh
```

That's it. The script creates a `venv` directory (already in `.gitignore`), installs everything from `requirements.txt`, and activates the virtual environment in your current shell.

!!! note "Ensure pip always runs in a virtual environment"

    If you set the environment variable `PIP_REQUIRE_VIRTUALENV` to
    `true`, `pip` will refuse to install anything outside a virtual
    environment. Forgetting to activate a `venv` can be very annoying
    as it will install all sorts of things outside virtual
    environments over time, possibly leading to further errors. So,
    you may want to add this to your `.bashrc` or `.zshrc` and
    re-start your shell:

```bash
export PIP_REQUIRE_VIRTUALENV=true
```

  [venv]: https://docs.python.org/3/library/venv.html
  [venv-activate]: https://docs.python.org/3/library/venv.html#how-venvs-work

### Live Preview

Start the live preview server with:

```
mkdocs serve
```

Point your browser to [localhost:8000][live preview] and you should see this
very documentation in front of you.

!!! warning "Automatically generated files"

    Never make any changes in the `material` directory, as the contents of this
    directory are automatically generated from the `src` directory and will be
    overwritten when the theme is built.

  [live preview]: http://localhost:8000

## Local Validation

Before submitting your pull request, run the validation script to catch issues early:

```bash
./scripts/validate-pr.sh
```

This script runs the same checks as our automated PR validation, including:

* Markdown linting
* MkDocs build test
* Link checking
* Spell checking
* YAML validation
* File naming conventions
* Image optimization checks
* Navigation structure validation
* IP address validation

### Required Dependencies

The setup script handles all Python packages. You also need these Node.js tools for full validation:

```bash
npm install -g markdownlint-cli2 markdown-link-check cspell
```

!!! tip "Skip missing tools"
    The script will warn about missing tools but continue with available checks.

## Dos and Don'ts

1. **Don't** just create a pull request with changes that are not explained.

2. **Do** discuss what you intend to do with people in the discussions so that the

   rationale for any changes is clear before you write or modify code.

3. **Do** link to the discussion or any issues to provide the context for a pull

   request.

4. **Do** ask questions if you are uncertain about anything.

5. **Do** ask yourself if what you are doing benefits the wider community and

   makes the AWS Networking Best Practices guide a better resource.

6. **Do** ask yourself if the cost of making the changes stands in a good

   relation to the benefits they will bring. Some otherwise sensible changes can
   add complexity for comparatively little gain, might break existing behavior
   or might be brittle when other changes need to be made.

7. **Do** merge in concurrent changes frequently to minimize the chance of

   conflicting changes that may be difficult to resolve.

## Common Issues

**Build errors?** Check that all markdown syntax is correct and links are valid.

**Merge conflicts?** Sync your fork with the main repository:

```bash
git remote add upstream https://github.com/aws/aws-networking-best-practices.git
git fetch upstream
git merge upstream/main
```

## Learning about pull requests

Pull requests are a concept layered on top of Git by services that provide Git
hosting. Before you consider making a pull request, you should familiarize
yourself with the documentation on GitHub, the service we are using. The
following articles are of particular importance:

1. [Forking a repository]{:target="_blank"}
2. [Creating a pull request from a fork]{:target="_blank"}
3. [Creating a pull request]{:target="_blank"}

Note that they provide tailored documentation for different operating systems
and different ways of interacting with GitHub. We do our best in the
documentation here to describe the process as it applies to the AWS Networking Best Practices guide
but cannot cover all possible combinations of tools and ways of doing things.
It is also important that you understand the concept of a pull-request in
general before continuing.

[Forking a repository]: https://docs.github.com/en/get-started/quickstart/fork-a-repo
[Creating a pull request from a fork]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork
[Creating a pull request]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request
