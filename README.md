# ia-to-hyacinth

A reusable script that uses an input CSV of IA (Internet Archive) to create an output CSV that can be imported by Hyacinth.

**Using ia-to-hyacinth**
`ruby ia-to-hyacinth.rb ia_entries.csv`
### Note: csv files MUST contain a field titled 'identifier' formatted 'ldpd_########_000'.

**Getting started on OSX**

1. Install tools
  - install Xcode command line tools

  - install [homebrew](http://brew.sh/)
  
        ````
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        ````
  - install git
  
        ````
        brew install git
        ````
  - install [rvm](http://rvm.io/rvm/install)

        ````
        \curl -sSL https://get.rvm.io | bash -s stable --ruby
        ````
  
2.  Get set up with git
  - create an account on github.com if you don't already have one
  - configure your git user name and email
  
        ````
        git config --global user.name "Your Name"
        git config --global user.email "your_email@whatever.com"
        ````

  - Install [github for mac](http://mac.github.com/) (optional, but has some very nice features) 

3. [Fork and clone](https://help.github.com/articles/fork-a-repo/) the repo
  - fork the https://github.com/cul/ia-to-hyacinth repo (fork button at top right of github web interface)
  - clone the new forked repo onto your dev machine
 
        ````
        git clone https://github.com/yourusername/ia-to-hyacinth        ````
 
4. Prepare your local environment
 - change to the app directory`cd ia-to-hyacinth`

 - check out the dev branch `git checkout dev`

 - run `bundle` to install the gems 
        
5. Run the test suite
  - run `rspec` and ensure that all tests are passing (green)