# 💁 Contributing to this project


> First off, thank you for considering contributing to this project.   
> It’s [people like you][ref-contributors] that keep this project alive and make it great!  
> Thank you! 🙏💜🎉👍

The following is a set of **guidelines for contributing** to this project. 
Use your best judgment and feel free to propose changes to this document in a pull request.

**Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/courses/how-to-contribute-to-an-open-source-project-on-github)

### 💡 Your contribution - the sky is the limit 🌈

This is an open source project and we love to receive contributions from our community — [**you**][ref-contributors]!   

There are many ways to contribute, from writing __tutorials__ or __blog posts__, improving the [__documentation__][ref-documentation], submitting [__bug reports__][ref-issues-new] and [__enhancement__][ref-pull-request-new] or 
[__writing code__][ref-pull-request-new] which can be incorporated into the repository itself.

When contributing to this project, please feel free to discuss the changes and ideas you wish to contribute with the repository owners before making a change by opening a [new issue][ref-issues-new] and add the **feature request** tag to that issue.

Note that we have a [code of conduct][ref-code-of-conduct], please follow it in all your interactions with the project.

### 🐞 You want to report a bug or file an issue?

1. Ensure that it was **not already reported** and is being worked on by checking [open issues][ref-issues].
2. Create a [new issue][ref-issues-new] with a **clear and descriptive title**
3. Write a **detailed comment** with as much relevant information as possible including
 - *how to reproduce* the bug 
 - a *code sample* or an *executable test case* demonstrating the expected behavior that is not occurring
 - any *files that could help* trace it down (i.e. logs)
  
### 🩹 You wrote a patch that fixes an issue?

1. Open a [new pull request (PR)][ref-pull-request-new] with the patch.
2. Ensure the PR description clearly describes the problem and solution. 
3. Link the relevant **issue** if applicable ([how to link issues in PRs][ref-pull-request-how-to]).
4. Ensure that [**no tests are failing**][ref-gh-actions] and **coding conventions** are met
5. Submit the patch and await review.

### 🎁 You want to suggest or contribute a new feature?

That's great, thank you! You rock 🤘 

If you want to dive deep and help out with development on this project, then first get the project [installed locally][ref-readme]. 
After that is done we suggest you have a look at tickets in our [issue tracker][ref-issues]. 
You can start by looking through the beginner or help-wanted issues: 
 - [__Good first issues__][ref-issues-first] are issues which should only require a few lines of code, and a test or two. 
 - [__Help wanted issues__][ref-issues-help] are issues which should be a bit more involved than beginner issues. 
These are meant to be a great way to get a smooth start and won't put you in front of the most complex parts of the system.

If you are up to more challenging tasks with a bigger scope, then there are a set of tickets with a __feature__, __enhancement__ or __improvement__ tag. 
These tickets have a general overview and description of the work required to finish. 
If you want to start somewhere, this would be a good place to start. 
That said, these aren't necessarily the easiest tickets. 

For any new contributions please consider these guidelines:

1. Open a [new pull request (PR)][ref-pull-request-new] with a **clear and descriptive title**
2. Write a **detailed comment** with as much relevant information as possible including:
 - What your feature is intended to do?
 - How it can be used?
 - What alternatives where considered, if any?
 - Has this feature impact on performance or stability of the project?

#### Your contribution responsibilities

Don't be intimidated by these responsibilities, they are easy to meet if you take your time to develop your feature 😌

- [x] Create issues for any major changes and enhancements that you wish to make. Discuss things transparently and get community feedback.
- [x] Ensure (cross-)platform compatibility for every change that's accepted. An addition should not reduce the number of platforms that the project supports.
- [x] Ensure **coding conventions** are met. Lint your code with the project's default tools. Project wide commands are available through the [Makefile][ref-makefile] in the repository root.
- [x] Add tests for your feature that prove it's working as expected. Code coverage should not drop below its previous value.
- [x] Ensure none of the existing tests are failing after adding your changes.
- [x] Document your public API code and ensure to add code comments where necessary.


### ⚙️ How to set up the environment

Please consult the [README][ref-readme] for installation instructions.

<!-- REFERENCES -->

[ref-code-of-conduct]: https://github.com/ctreffs/SwiftImGui/blob/master/CODE_OF_CONDUCT.md
[ref-contributors]: https://github.com/ctreffs/SwiftImGui/graphs/contributors
[ref-documentation]: https://github.com/ctreffs/SwiftImGui/wiki
[ref-gh-actions]: https://github.com/ctreffs/SwiftImGui/actions
[ref-issues-first]: https://github.com/ctreffs/SwiftImGui/issues?q=is%3Aopen+is%3Aissue+label%3A"good+first+issue"
[ref-issues-help]: https://github.com/ctreffs/SwiftImGui/issues?q=is%3Aopen+is%3Aissue+label%3A"help+wanted"
[ref-issues-new]: https://github.com/ctreffs/SwiftImGui/issues/new/choose
[ref-issues]: https://github.com/ctreffs/SwiftImGui/issues
[ref-pull-request-how-to]: https://docs.github.com/github/writing-on-github/autolinked-references-and-urls
[ref-pull-request-new]: https://github.com/ctreffs/SwiftImGui/compare
[ref-readme]: https://github.com/ctreffs/SwiftImGui/blob/master/README.md
[ref-makefile]: https://github.com/ctreffs/SwiftImGui/blob/master/Makefile
