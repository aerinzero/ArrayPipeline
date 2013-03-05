# Contributing Guidelines
Thanks for taking the time to contribute to the ArrayPipeline Mixin.  The following is a set of 
guidelines to follow when contributing to the project.

If you have any questions, please tweet **@NivenHuH** or file a GitHub Issue.

# Contributing Code
We welcome and embrace Pull Requests from contributors.  For instructions on how to test and build,
please see the [Tasks](#Tasks) section.

When submitting a Pull Request, please do the following:

* Develop a failing test case 
* Write code that makes the test case pass
* Squish your commits to a single commit
* Include any relevant issue numbers that may be fixed or updated by the PR.  Eg: (Fixes #1, 
  Updates #2)
* Have a descriptive commit message that explains what was changed

# Features
If you have a new feature to request, please search GitHub Issues for a similar request.  If you
find one, please chime in with a :+1:.  

If you do not find an existing request, please file one.  In your issue, please mention:

* Description of the feature
* Description of how you would use the feature
* If available, a proposed solution

We will gladly accept pull requests for highly requested features.  We will fix issues / implement
new features as time permits.

# Bugs
If you have encountered a bug, please do any **one** of the following (in order of preference):

* Submit a failing test case
* Submit a GitHub Issue with a link to a jsbin/jsfiddle that exhibits the problem and a description
* Submit a GitHub Issue with a thorough description of the problem, what was expected, and what 
  occurred.  

# Setting Up Build Environment
The build environment relies on the [Rake Pipeline](https://github.com/livingsocial/rake-pipeline) 
gem, Ruby, [Bundler](http://gembundler.com/) as well as a few other dependencies.  To setup the 
build environment, please do the following:

1. Install Ruby
2. Install [Bundler](http://gembundler.com)
3. Run ```bundle install```
4. Install Node
5. Run ```npm install```

# Tasks
To get a list of tasks available for building, testing, cleaning, etc... run ```rake -T```.  Here
is the current list (as of the time of writing this document).

```
rake build       # Trigger a build and put files into dist/ directory
rake clean       # Clean the dist/ directory
rake test:run    # Run the test suite once
rake test:watch  # Run and watch the test suite
rake watch       # Watch for changes in src/ and trigger a build on change
```
