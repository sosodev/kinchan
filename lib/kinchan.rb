# frozen_string_literal: true

require 'kinchan/version'
require 'selenium-webdriver'
require 'require_all'

# Top-level module contains all the juicy bits for the gem
module Kinchan
  @browser = :chrome
  @browser_options = nil

  def self.browser
    @browser
  end

  def self.browser=(browser)
    @browser = browser
  end

  def self.browser_options
    @browser_options
  end

  def self.browser_options=(browser_options)
    @browser_options = browser_options
  end

  def self.restore_defaults
    @browser = :chrome
    @browser_options = nil
  end

  # A single unit of automation in Kinchan
  class Task
    singleton_class.send(:attr_accessor, :browser)
    singleton_class.send(:attr_accessor, :browser_options)
    singleton_class.send(:attr_reader, :descendants)
    @descendants = []

    def initialize(**options)
      @before_tasks = []
      @after_tasks = []
      @options = options

      Task.start_browser unless defined?(@@browser_webdriver)
    end

    def self.inherited(subclass)
      Task.descendants << subclass
    end

    def self.find_task(task_symbol)
      Task.descendants.select { |task| task.name.split('::').last.downcase == task_symbol.to_s.downcase }[0]
    end

    def self.start_browser
      browser = Kinchan.browser
      browser_options = Kinchan.browser_options

      @@browser_webdriver = if browser_options.nil?
                              Selenium::WebDriver.for browser
                            else
                              Selenium::WebDriver.for(browser, options: browser_options)
                            end
    end

    def self.restart_browser
      return if @@browser_webdriver.nil?

      @@browser_webdriver.close
      @@browser_webdriver = Selenium::WebDriver.for Kinchan.browser
    end

    def execute(_browser); end

    def run
      run_tasks(@before_tasks)
      execute(@@browser_webdriver)
      run_tasks(@after_tasks)
    end

    private

    def get_task(task_hash)
      task = Task.find_task(task_hash[:task])
      options = task_hash[:options]

      if options.nil?
        task.new
      else
        task.new(**options)
      end
    end

    def run_tasks(tasks)
      tasks.each do |task_hash|
        get_task(task_hash)&.public_send('run')
      end
    end
  end
end

require_all 'tasks' if File.directory?('tasks')
