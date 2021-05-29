# Discussion
This project took a while. Not because the logic was particularly difficult, but because of self-study burnout. It was my first time going at a sluggish pace for the many courses I've done over the past year. However, as might be evident by it actually being completed, I was *very* keen to move on.

## Planning
If you are trying to tackle a large program for which you want to make DRY enough code, with mostly small, readable and easily changed/improved methods and classes, then planning is a must. Typically, for projects big and small, I do some planning in the form of:
### Typically for projects
- Main classes/modules
- Important logic
- Some pseudo code or small descriptions of *important* methods' behaviours
For a bigger project like this, it was important to get down most. You **do not** need to plan for everything, not even most things. You just need enough for you to feel comfortable and for you to understand the requirements of the project:
### Especially for a bigger project
- File structure
  - directories, file names and main file methods (plus whether it's a class/module)
- Class, module and method behaviour
  - the main aim of a class or module and the key behaviours of *important* methods
  - not everything is needed, but you want to give yourself a headstart
- Testing methodlogy (massive time saver in planning and practise)
  - which files/classes you want to test and which classes (if any) for which you will use TDD
- Git workflow
  - knowing when to not rebase and using branches
  - (TIP:) commit often... something I still need practise with doing
### From plan to project
By having such a plan, which you can add to any time, I found it much easier to start coding and creating. The most basic version of my plan did not take much time, but it yielded great returns. I recommend making a plan for your projet including just enough to make you comfortable to go from plan to project.

## Aim and tasks
The aim of this was to create a chess game can be played by two players, can be saved (and loaded) and looks semi-appealing. The main tasks were to:
- Constrain to legal moves only
  - following the rules of chess (check, mate, castling and so on)
- Allow the board to be saved
  - seemingly optionally needing the abiloty to load but it felt right to have it
- Write tests
  - TDD if desired
- Neat and modular design
  - for easy bug fixing and less stressful development
I cannot stress enough how useful it was to write tests. It really gave me a peace of mind and made it easy to identify where issues where (for a modular design).

## Difficulties
As with any big project, there are going to be some hardships. As mentioned before I had some burnout from consistently learning different programming-related things from different courses (e.g. data viz and ML). However I had some other issues when it came to coding the program. Perhaps unexpectedly, the main logic was by far the simplest part (capture, check, mate etc.) and I had that done before I started (from the fruits of planning). On the other hand...
### Input
the *game.rb* file is principally responsible for handling input and acting as a liason between the other modules. Getting other modules to behave together was quite challenging. They would work on their own, even pass all their tests, but when put together it became easy to lose track of what input/data was where at a given time. In no small part, this is due to my design but it felt like a general challenge.
### Mocks, stubs and doubles (for input and processing)
Testing was very useful to mitigate potentially iritating issues and to give you reassurance or emphasis on the working parts of your classes. Key to this were [mocks, stubs and doubles](http://testing-for-beginners.rubymonstas.org/test_doubles.html). However, when [unit testing](https://www.artofunittesting.com/definition-of-a-unit-test) it can result in an unrepresentative series of tests, at least when you're as inexperienced as I am. Even when all my tests passed, my program would still have issues, driving home that my tests which relied heavily on mocks assumed that the stubbed/mocked method was handling appropriate input. As stated in "difficulties", the input can sometimes elude. In other words, you won't catch everything but these tests do still go a long way towards helping you catch most issues.

## Resources
I found some really nice resources and information from doing this project many of which I wish I could mentally ingest. Since I cannot, I keep a very organised collection of bookmarks that I reference when needed and, like on other projects, I like sharing my resources. My most notable resources were:
### Used - git and terminal
- Restoring corrupted commits (https://stackoverflow.com/questions/11706215/how-to-fix-git-error-object-file-is-empty)
  - I messed up with git, but I keep a folder for just that occasaion and that came in very useful
- How to git (https://sethrobertson.github.io/GitBestPractices/)
  - I'm not all the way there yet, but I used this to get an idea of what a git workflow was like and what I should do
- How to git officially (https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
  - Very useful in understanding the different options and use-cases
- Using git log effectively (https://stackoverflow.com/questions/7131703/how-to-know-which-branch-a-git-log-commit-belongs-to)
  - Allowed me to understand what was on each branch
  - *git log --cherry --right-only A...B* -> everything in B that is not in A (commit/branch)
    - Super useful command as I got confused a lot since it was my first time dealing with the branching workflow
- Making things colourful (https://misc.flogisoft.com/bash/tip_colors_and_formatting)
  - Just to bring my program to life a little bit
- A better editor (https://coderwall.com/p/adv71w/basic-vim-commands-for-getting-started)
  - Vim is quite a bit nicer than what I used before
### Used - ruby and testing
- Cloning using Marshal (https://stackoverflow.com/questions/8691496/instance-variable-still-references-after-dup)
  - Allows different object references which I needed when I took snapshots of the game board
- Why you should test (https://www.madetech.com/blog/9-benefits-of-test-driven-development)
  - So that I knew what I should be looking for when I decided to test something
- Heredocs and short-hand syntax (https://commandercoriander.net/blog/2014/11/09/a-multiline-string-cheatsheet-for-ruby/)
- Set operators (https://www.endpoint.com/blog/2011/06/07/using-set-operators-with-ruby-arrays)
  - I used "-" at a few points to get the difference between arrays
- Understanding blocks and procs (https://www.rubyguides.com/2016/02/ruby-procs-and-lambdas/)
  - Lamdas are familar to me from Python, but learning how to leverage Ruby Procs and blocks was so rewarding
### To be used
- Escape Sequences and ANSI code (https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797)
  - Will be used to organise display elements so that I can properly format information on the terminal
- Error handling (https://www.sitepoint.com/ruby-error-handling-beyond-basics/)
  - I think it's a nice project to implement this on, even if it is not my first

## Final Comments
This was a fun project to do, in spite of the difficulties and I learnt a lot that I intend to use in my future projects. Hopefully there was some useful information for anyone reading this whether from my experience or the resources I used (i.e. others' experiences and expertise). There is still work to do, but the foundation is great! Let me know of any thoughts/comments you have.