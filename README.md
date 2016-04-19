# tldr

The PoshCode *tldr* module is a collection of simplified and community-driven example pages to help you quickly the the gist of commands.

## What does tldr mean?

TL;DR stands for "Too Long; Didn't Read".
It has its origins in internet and email slang, where it is used to indicate parts of a text were skipped as too lengthy to read.
Read more in the [TLDR article on Wikipedia](https://en.wikipedia.org/wiki/TL;DR).

## What is tldr?

It's a help module for people like me...

When I look at command help, I usually only care about two things: 

1. The syntax
2. Some examples

I'm always frustrated when a command has a lot of description text, causing the syntax block to scroll right off the top of the page in PowerShell.  I'm also frustrated when there are pages and pages of examples that don't actually do anything useful (like, how could there be 74 lines of examples for Set-ACL without a single example that doesn't just copy the ACL from another file?).

You are like me if you would prefer simple syntax blocks and "show me common usage" in your help. Something like this:

![tldr screenshot](http://raw.github.com/poshcode/tldr/gh-pages/images/screenshot.png)

Or maybe you're just frustrated that in 74 lines of the `Get-Help Set-Acl -Examples` there's not a single example that doesn't just copy the ACL from one file to another.

This module and repository is an ever-growing collection of high-quality real-world examples for the most common PowerShell commands, and some code to generate starter files from the help documentation already available with your commands.

### `tldr` is for you if you ever

* Find a new module and want a quick overview? 
* Need a reminder about a command's syntax?
* Can't remember how to pass that one parameter?
* Can't remember the syntax for commands you only use once in a blue moon?

## Antecedents

I've borrowed the idea from a similar linux project, [tldr-pages](http://tldr-pages.github.io/), and so I expect that once we have a little content we should be able to modify [their clients](https://github.com/tldr-pages/tldr#clients), including the interactive web client and android client to point at this repository and get PowerShell examples.

## Contributing

- Your favourite command isn't covered?
- You can think of more examples for an existing command?

Contributions are most welcome!
Have a look at the [contributing guidelines](CONTRIBUTING.md)
and help us out!
