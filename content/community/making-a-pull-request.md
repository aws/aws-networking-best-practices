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

## Step-by-Step Process

### 1. Fork the repository on GitHub

1. Go to the [aws-networking-best-practices] repository on GitHub
2. Click on the 'Fork' action at the top, to the right of the "aws-networking-best-practices" banner.
3. Fork the repository into your own space - you can name it whatever you like, although keeping it as `aws-networking-best-practices` is recommended.

[aws-networking-best-practices]: https://github.com/aws/aws-networking-best-practices

### 2. Create a branch for your changes

Checkout the main branch of your own fork:

1. cd to a clean directory
2. Do `git clone git@github.com:(fork path)` - You can get the fork path by clicking the green "Code" dropdown in the website for your fork, selecting the SSH tab, and copying the path from there
3. Prepare your environment - see [Environment setup](#environment-setup) below.

We strongly recommend you use branching in your fork. To do so, make a branch by `git checkout -b (new-branch-name)`.  The branch name should be something short but meaningful to what you're doing - `add-new-service-info` or such. A full description will come later.

### 3. Make your edits and commit them

1. Edit the documentation files. Use whatever tool you like, although having one that allows Markdown preview is very helpful. Ensure you follow the patterns laid out in other sections - consistency in look and feel is important.

2. Commit changes in logical chunks with clear messages. Do this by:
    * Do `git add (files that have been changed)`. If there are old files no longer needed, remove them from the repo with `git rm (files to remove)`
    * Do `git status` to verify you are on a branch, and the files you want changed show under `Changes to be committed:`
    * Do `git commit -m "Brief message describing your changes"` - This message should be short (60 characters or so), as it is what will show up as a comment next to files you are changing.
    * If everything looks good, so `git push origin (branch-name)`.

3. If you are the fork owner, manage your fork by accepting the branches into your main for consistency. 
    * You should resync your main from the aws fork before doing this by going to the GitHub website and clicking 'Sync fork'.
    * Do `git checkout main`
    * Do `git pull` to ensure you're up-to-date
    * Do `git merge (branch-name)`
    * Do `git commit -m "Same message as the branch message"`
    * Do `git push origin main`

### 4. Submit a pull request with a clear description

1. Go through the [Local Validation](#local-validation) steps below right before you're ready for your work to be sent to the main site for review.
2. Go to the GitHub web page (you can do this from either the main site or your fork), go to the 'Pull requests' tab at the top, and click 'New pull request'. Ensure the left side is 'aws/aws-networking-best-practices', branch 'main', and the right side is your fork and correct branch (likely main, if you followed the steps above). Fill out the pre-filled text at the top of the PR, and check the boxes needed (in Markdown editor, use `[x]` to check boxes).
3. Submit your pull request.

### 5. Review Process

* Respond to reviewer feedback promptly

* Make requested changes and push updates

* Your PR will be merged once approved

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

    ```
    git clone (fork-url)
    cd aws-networking-best-practices
    ```
Next, create a new [Python virtual environment][venv] and
[activate][venv-activate] it:

```
python -m venv venv
source venv/bin/activate
```

!!! note "Ensure pip always runs in a virtual environment"

    If you set the environment variable `PIP_REQUIRE_VIRTUALENV` to
    `true`, `pip` will refuse to install anything outside a virtual
    environment. Forgetting to activate a `venv` can be very annoying
    as it will install all sorts of things outside virtual
    environments over time, possibly leading to further errors. So,
    you may want to add this to your `.bashrc` or `.zshrc` and
    re-start your shell:

    ```
    export PIP_REQUIRE_VIRTUALENV=true
    ```

  [venv]: https://docs.python.org/3/library/venv.html
  [venv-activate]: https://docs.python.org/3/library/venv.html#how-venvs-work

Then, install all Python dependencies:

    ```
    pip install \
                mkdocs-material \
                mkdocs-git-revision-date-localized-plugin \
                mkdocs-git-committers-plugin-2 \
                "mkdocs-material[imaging]"
    ```

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

Install these tools for full validation:

**Node.js packages:**

```bash
npm install -g markdownlint-cli2 markdown-link-check cspell
```

**Python packages:**

```bash
pip install yamllint mkdocs-material
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

1. [Forking a repository]
2. [Creating a pull request from a fork]
3. [Creating a pull request]

Note that they provide tailored documentation for different operating systems
and different ways of interacting with GitHub. We do our best in the
documentation here to describe the process as it applies to the AWS Networking Best Practices guide
but cannot cover all possible combinations of tools and ways of doing things.
It is also important that you understand the concept of a pull-request in
general before continuing.

[Forking a repository]: https://docs.github.com/en/get-started/quickstart/fork-a-repo
[Creating a pull request from a fork]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork
[Creating a pull request]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request
