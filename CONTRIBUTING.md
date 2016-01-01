# Contributing

Contribution are very welcome! All of our `tldr` pages are written in Markdown and stored right here on GitHub. Just open an issue or send a pull request and we'll merge it as soon as possible.

*Note*: when submitting a new command, don't forget to check if there's already a pull request in progress.

## Guidelines

Note that `tldr` is focused on concrete examples.
Here's a few guidelines to get started:

1. Focus on the 5 or 6 most common usages. It's OK if the page doesn't cover everything; that's what `Get-Help` is for.
2. Introduce parameters gradually, starting with the simplest commands and using progressively more complex examples.
3. Use short but descriptive variable names for the values, e.g. `$SourceFile` or `$Credentials`.
4. Be specific to the command you're writing examples for. Avoid explaining general PowerShell concepts that could apply to any command -- we don't need examples that show how to sort, filter, or format the results!
5. When in doubt, keep in mind most readers are IT professionals, focus on the usefulness of the command, not teaching PowerShell.
6. Remember to keep descriptions **very** short so they don't wrap. Just explain _what_ the example does, don't explain how -- that _should_ be obvious.
 
The best way to be consistent is to have a look at a few existing pages :)

## Quick Start

If your command has existing help (comment or XML based) that shows up in Get-Help, you should be able to generate a page to get you started by just calling `tldr $YourCommand`.

However, the generated pages practically never match our guidelines, because the typical examples from PowerShell help are simplistic and extremely verbose, and their descriptions are almost ridiculously repetitive.

You will need to carefully edit the pages to get something useful, and drastically reduce the description (although the generated page will have only the first paragraph of the help descriptions, you will almost always need to shorten it a lot more).

## Markdown format

The format of each page should match the following:

```posh
# command-name

> Synopsis (from the command help?)
> Maximum of 1 or 2 lines

- example description

`Verb-Noun -Switch1 -Switch2 -param1 ${ParameterValue}`

- example description

`Verb-Noun -Switch1 -Switch3`

## Full Syntax

`Verb-Noun [-Switch1] [-Switch2] [[-Param1] <String>]`
`Verb-Noun [-Switch1] [-Switch3]`

```

User-provided values should use the `${Variable}` syntax (with the curly braces) to allow clients to highlight them. For example: `Compress-Archive -Path ${FileList} -Destination ${OutputFolder}`

One of the reasons for this format is that it's well suited for command-line clients that need to extract a single description and example.

Note that the final `## Full Syntax` blocks can be missing, but should not be incomplete -- that is, you may leave off the full syntax (for commands that are available on the user's machine, we can generate that), but if you do include it, please include all the parameter sets just as PowerShell would output them (this will be used if the command is not available on the user's box).

## Submitting a pull request

TL;DR: fork, feature branch, commit, push, pull request.

Detailed explanation:

1. [Fork](http://help.github.com/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone https://github.com/<your-username>/tldr
   # Navigate to the newly cloned directory
   cd tldr
   # Assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/poshcode/tldr
   ```

2. If you cloned a while ago, get the latest changes from upstream:

   ```bash
   git checkout master
   git pull upstream master
   ```

3. Create a new topic branch (sometimes they are called feature branches) off
   the main project development branch:

   ```bash
   git checkout -b feature/<feature-name>
   ```

4. Please use the following commit message format: 
   `<command>: type of change`.

   Examples:

   - `Get-ChildItem: Add page`
   - `Get-Content: Fix typo`
   - `Set-Content: Add -force example`
   - `Rename-Item: fix -passthru example`

7. Push your topic branch up to your fork:

   ```bash
   git push origin feature/<feature-name>
   ```

8. [Open a Pull Request](https://help.github.com/articles/using-pull-requests/)
    with a clear title and description.

9. Use Git's
   [interactive rebase](https://help.github.com/articles/interactive-rebase)
   feature to tidy up your commits before making them public.
   In many cases it is better to squash commits before submitting a pull request.

10. If you are asked to amend your changes before they can be merged in, please
   use `git commit --amend` and force push to your remote feature branch.
   You _may_ also be asked to squash commits.


## Licensing

`tldr` is under [MIT license](https://github.com/tldr-pages/tldr/blob/master/LICENSE.md).

**IMPORTANT**: By submitting a patch, you agree to license your work under the
same license as that used by the project.