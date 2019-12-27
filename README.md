# [Kinchan](https://itazuranakiss.fandom.com/wiki/Kinnosuke_Ikezawa)
## Composable browser automation for Ruby.

### Requirements

* Ruby
* Bundler

### Getting Started

Create a new directory for your Kinchan project

`mkdir kinchan_project && cd kinchan_project`

Create the tasks directory where you'll store your Kinchan tasks

`mkdir tasks`

Initialize bundler

`bundle init`

Add the Kinchan gem to your bundle

`bundle add kinchan`

Now that we've got the structure the rest of the readme will teach you how to create, compose, and run Kinchan tasks 👽 

### Creating a Task

In your tasks directory create a Ruby file with any name

e.g. `touch ruby_reddit.rb`

In your task's Ruby file you'll need to `require 'kinchan'`

and then define your task as a class that inherits from `Kinchan::Task`

so far your file should look a little something like this
```ruby
require 'kinchan'

class VisitRubysReddit < Kinchan::Task
end
```

All Kinchan tasks require an execute method that takes a single parameter (the selenium browser object) like so

```ruby
require 'kinchan'

class VisitRubyReddit < Kinchan::Task
  def execute(browser)
    browser.navigate.to 'https://old.reddit.com/r/ruby'
  end
end
```

That's all it takes to create a basic task! If we run it we'll see a browser process start and navigate to the Ruby subreddit. For a full description of the 
browser API check out the [wiki page](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings) for Ruby Selenium (they call it a "driver").

### Running a Task

Create a Ruby file in the root level of your Kinchan project and require your task

Create a new instance of the task and call `run`

e.g.

```ruby
require_relative 'tasks/ruby_reddit'

VisitRubyReddit.new.run
```

That's all it takes to run a task. Kinchan handles the rest.

### Passing Data to a Task

A task's initialize function can accept options, just don't forget to call super

e.g.

```ruby
class Search < Kinchan::Task
  def initialize(**options)
    super
    @query = options[:query]
  end

  def execute(browser)
    browser.navigate.to 'https://www.google.com/search?q=#{CGI.escape(@query)}'
  end
end
```

### Composing Tasks

Tasks can call any number of other tasks either before or after they execute, and their dependencies
will have their dependencies ran and so on

This is done by specifying dependencies with a task's `@before_tasks` or `@after_tasks` in their initialize method

e.g.

```ruby
class PrintFirstResult < Kinchan::Task
  def initialize(**options)
    super
    @before_tasks << { task: :search, options: options }
    # specify that the search task should run, with the same options, before running this task
  end

  def execute(browser)
    puts browser.execute_script "return document.querySelector('.srg a').innerText"
  end
end
```

Task's do not need to be in the same scope, as long as the task exists Kinchan will find and run it when appropriate

### Setting Selenium Browser Options

before running your task you can modify the selenium browser options like so

```ruby
Kinchan::Task.browser = :chrome
Kinchan::Task.browser_options = Selenium::WebDriver::Chrome::Options.new
Kinchan::Task.browser_options.add_argument('--headless')
```
