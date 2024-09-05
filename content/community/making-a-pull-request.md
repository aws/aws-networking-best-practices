# Pull Requests

You can contribute to the AWS Networking Best Practices guide by making a 
[pull request] that will be reviewed by maintainers and integrated into the
main repository when the changes made are approved. You can contribute corrections
to the existing guide or new best practices.

[pull request]: https://docs.github.com/en/pull-requests

!!! note "Considering a pull request"

    Before deciding to spend effort on making changes and creating a pull
    request, please discuss what you intend to do. If you are responding to
    what you think might be a correction, please issue a [correction report] first.
    If you intend to work on a new best practices documentation, create a 
    [new best practice issue].

    Keep in mind the guidance given and let people advise you. It might be that
    there are easier solutions to the problem you perceive and want to address.

[correction report]: report-a-correction.md
[new best practice issue]: new-best-practice.md

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

## Pull request process

In the following, we describe the general process for making pull requests. The
aim here is to provide the 30k ft overview before describing details later on.

### Preparing changes and draft PR

The diagram below describes what typically happens to repositories in the
process or preparing a pull request. We will be discussing the review-revise
process below. It is important that you understand the overall process first
before you worry about specific commands. This is why we cover this first before
providing instructions below.

``` mermaid
sequenceDiagram
  autonumber

  participant aws-networking-best-practices
  participant PR
  participant fork
  participant local

  aws-networking-best-practices ->> fork: fork on GitHub
  fork ->> local: clone to local
  local ->> local: branch
  loop prepare
    loop push
      loop edit
        local ->> local: commit
      end
      local ->> fork: push
    end
    aws-networking-best-practices ->> fork: merge in any changes
    fork ->>+ PR: create draft PR
    PR ->> PR: review your changes
  end
```

1. The first step is that you create a fork of the AWS Networking Best Practices guide
   repository [aws-networking-best-practices]. This provides you with a repository that you
   can push changes to. Note that it is not possible to have more than one fork
   of a given repository at any point in time. So, the fork you create will be
   *the* fork you have.

2. Once it is made, clone it to your local machine so you can start working on
   your changes.

3. All contributions should be made through a 'topic branch' with a name that
   describes the work being done. This allows you to have more than one piece
   of work in progress and, if you are working with the public version, also
   shows others clearly that the code contained is work in progress. The topic
   branch will be relatively short-lived and will disappear at the end, when
   your changes have been incorporated into the codebase.

4.  Next comes the iterative process of making edits, committing them to your
    clone. Please commit in sensible chunks that constitute a piece of work
    instead of committing everything in one go.

    Remember that fine-grained, incremental commits are much easier to
    review in than large changes all over the place and with many files involved.
    Try to keep your changes as small and localized as possible and keep the
    reviewer in mind when committing. In particular, make sure to write
    meaningful commit messages.

5. Push your work up to your fork regularly.

6. You should also keep an eye on changes in the AWS Networking Best Practices guide repository
   you cloned. This is especially important if you work takes a while. Please
   try and merge any concurrent changes into your fork and into your branch
   regularly. You *must* do this at least once before creating a pull request,
   so make your life easier and do it more often so as to minimize the risk of
   conflicting changes.

8. Once you are happy that your changes are in a state that you can describe
   them in a *draft* pull request, you should create this. Make sure to
   reference any previous discussions or issues that gave rise to your work.
   Creating a draft is a good way to get *early* feedback on your work from the
   maintainer or others. You can explicitly request reviews at points where you
   think this would be important.

9.  Review your work as if you were the reviewer and fix any issues with your
    work so far. Look critically at the diffs of the files that you have changed.
    In particular, pay attention to whether the changes are as small as possible
    and whether you have follow the general coding style used in the project.
    If you received feedback, iterate over the process so far as necessary.

    You should choose a number of projects to test your changes with. You should
    definitely make sure that the changes do not break the building of the
    documentation for the AWS Networking Best Practices guide.

[aws-networking-best-practices]: https://github.com/aws/aws-networking-best-practices

### Finalizing

Once you are happy with your changes, you can move to the next step, finalizing
your pull request and asking for a more formal and detailed review. The diagram
below shows the process:

``` mermaid
sequenceDiagram
  autonumber
  participant aws-networking-best-practices
  participant PR
  participant fork
  participant local

  activate PR
  PR ->> PR : finalize PR
  loop review
    loop discuss
      PR ->> PR: request review
      PR ->> PR: discussion
      local ->> fork: push further changes
    end
    PR ->> aws-networking-best-practices: merge (and squash)
    deactivate PR
    fork ->> fork: delete branch
    aws-networking-best-practices ->> fork: pull
    local ->> local: delete branch
    fork ->> local: pull
  end
```

1. When you are happy that the changes you made amount to a contribution that
   the maintainers could integrate into the codebase, finalize the pull
   request. This signals to everyone that consider the work 'done' and that it
   can be reviewed with a view to accepting and integrating it.

2.  The maintainers may make comments on your code, which you should discuss with
    them. Bear in mind when doing this that the maintainers may have a different
    point of view compared to yours. They will often take a more long-term
    perspective of maintaining the project in the years to come while you may be
    more focused on the specific issue or feature that you worked on. Please keep
    the discussion respectful at all times.

    It is important to note that not all pull requests get incorporated int the
    codebase. The reasons can vary. The work may bring to light other issues that
    block integration of the pull request. Sometimes it helps uncover better ways of
    doing things or shows that a more general approach is needed. All of this is
    fine and helps the project progress, even if specific changes are not,
    ultimately, accepted.

3. Make any requested changes by committing them to your local clone and
   pushing them up to your fork. This will automatically update the pull request.
   It may well take a few iterations to get your contributions to an acceptable
   state. You can help the process along by carefully reading comments made and
   making changes with care.

4. Once the reviewer is fully satisfied with the changes, they can merge them
   into the main branch. In the process, they may 'squash' your
   commits together into a smaller number of commits and may edit the messages
   that describe them. Congratulations, you have now contributed to this project
   and should see the changes in the main branch under your name.

5. You can now delete the fork and your local repository and start afresh again
   next time around. Alternatively, you can keep the repository and local clone
   around but it is important that you keep them in sync with the upstream
   repository for any subsequent work. We recommend that you start by deleting
   the branch you used on your fork.

6. To make sure you have the changes you produced, pull them from the main
   repository into the main branch of your fork.

7. Similarly, delete the topic branch from your local clone and...

8. pull the changes to its main branch.

## Steps

Now that the overall process is outlined, here are specific instructions and
tips. There are many choices to be made when describing a process for
contributing to a project via a pull request. In the following, we assume that
you are working with the Git command-line tools. For most alternatives (such as
using IDEs or using functionality provided through the GitHub web interface),
the translation from the command-line instructions should be simple enough.  We
will add notes only where really necessary to keep the complexity of this to a
reasonable level.

### Forking the repository

To make changes to the AWS Networking Best Practices guide, you would first fork one of its
repositories on GitHub. This is so that you have a repository on GitHub that
you can push changes to (only maintainers and collaborators have write access
to the original repositories).

It is a good idea to change the name of the repository by
appending `-fork` so that people who come across it know that they have found a
temporary fork rather then the original or a permanent fork of the project.
You may also want to add a description that clarifies what the repository is for.

### Setting up a development environment

From this point onwards, please follow the [instructions for setting up the
development environment]. They will take you through the process of setting up
an environment in which you can make changes and review/test them.

[instructions for setting up the development environment]: #environment-setup

### Making changes

When you make changes to the documentation please follow the
established style used in the project. Doing so increases readability and
also helps with making diffs easier to read for those who will review the pull
request. Avoid making any large-scale style changes such as asking your IDE
to re-format all code.

Study documentation markup that you are modifying well to ensure that you fully understand
how it works before you try to change it. This will not only help you solve the
problem you are trying to address but also minimize the risks of creating
unintended side effects.

### Committing to a branch

Development for pull requests is best done in a topic branch separate from the
`main` branch. Create a new local branch with `git switch -c <name>` and
commit your changes to this branch.

When you want to push commits to your fork, you can do so with
`git push -u origin <name>`. The `-u` argument is the short version of
`--set-upstream`, which makes the newly created branch 'track' the branch with
the same `<name>` in your fork. This means that then `pull` and `push` commands
will work against that branch in your fork by default.

### Merging concurrent changes

If the work you do takes some time then the chances increase that changes will
be made to the main repository while you work.It is probably a good idea to set
up the original the AWS Networking Best Practices guide repository as an `upstream` repository for
your local clone.

This is what it might look like:

```bash hl_lines="4"
$ git remote -v
origin	git@github.com:<your_username>/aws-networking-best-practices.git (fetch)
origin	git@github.com:<your_username>/aws-networking-best-practices.git (push)
$ git remote add upstream https://github.com/aws/aws-networking-best-practices.git
$ git remote -v
origin	git@github.com:<your_username>/aws-networking-best-practices.git (fetch)
origin	git@github.com:<your_username>/aws-networking-best-practices.git (push)
upstream	https://github.com/aws/aws-networking-best-practices.git (fetch)
upstream	https://github.com/aws/aws-networking-best-practices.git (push)
```

After you have done this, you can pull any concurrent changes from the upstream
repository directly into your clone and do any necessary merges there, then push
them up to your fork. You will need to be explicit about which remote repository
you want to use when you are doing a `pull`:

```bash
# making and committing some local changes
push pull upstream master
```

This fetches changes from the `master` branch into your topic branch and merges
them.

### Testing and reviewing changes

Before you commit any changes, you should make sure that they work as expected
and do not create any unintended side effects. You should test them on at least
this [smoke tests]:

- The documentation of the AWS Networking Best Practices guide itself. If you set up and run the
development environment as outlined in the [instructions for setting up the
development environment], `mkdocs serve` should be running and continuously
building the documentation. Check that there are no error messages and, ideally,
no (new) warnings.

[smoke tests]: https://en.wikipedia.org/wiki/Smoke_testing_(software)

### Creating the pull request

Initially, create the pull request **as a draft**. You do this [through the
various interfaces that GitHub provides]. Which one you use is entirely up to
you. We do not provide specific instructions for using the interfaces as GitHub
provide all the information that should be necessary.

[through the various interfaces that GitHub provides]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request

### Commits, messages, mistakes and 'squash'

### Deleting branches

Once the pull request has been merged into the master branch of the AWS Networking Best Practices
repository, you should remove the branch both from the fork on
GitHub and from the local clone on your computer. This avoids possible
confusion about the state of development.

First, switch back to the `main` branch with `git switch main` and then
delete the branch used for the PR using `git branch -d <name>`.

### Subsequent Pull Requests

It is important that subsequent pull requests are started from an up-to-date
history of the `main` branch. One way to achieve this is to delete the fork
and start with an entirely new one next time round.

If you contribute to the AWS Networking Best Practices guide more often or just happen to be
doing two or more pull requests in succession, you can also just make sure
to sync your fork (using the GitHub UI) and pull from it into your local
repository. So, just delete the topic branch you created (both locally and in
your fork) and pull from the main repository's `main` branch into your
`main` branch before starting work on a new pull request.

## Dos and Don'ts

1. **Don't** just create a pull request with changes that are not explained.

2. **Do** discuss what you intend to do with people in the discussions so that the
   rational for any changes is clear before you write or modify code.

3. **Do** link to the discussion or any issues to provide the context for a pull
   request.

4. **Do** ask questions if you are uncertain about anything.

5. **Do** ask yourself if what you are doing benefits the wider community and
   makes the AWS Networking Best Practices guide a better resource.

6. **Do** ask yourself if the cost of making the changes stands in a good
   relation to the benefits they will bring. Some otherwise sensible changes can
   add complexity for comparatively little gain, might break existing behaviour
   or might be brittle when other changes need to be made.

7. **Do** merge in concurrent changes frequently to minimize the chance of
   conflicting changes that may be difficult to resolve.

## Environment setup

First, clone the repository.

    ```
    git clone https://github.com/aws/aws-networking-best-practices
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