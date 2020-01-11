# frozen_string_literal: true

require 'kinchan/version'
require 'selenium-webdriver'
require 'require_all'

module Kinchan
  @browser = :chrome
  @browser_options = nil

  def self.browser
    @browser
  end

  def self.browser= b
    @browser = b
  end

  def self.browser_options
    @browser_options
  end

  def self.browser_options= bo
    @browser_options = bo
  end

  class Task
    singleton_class.send(:attr_accessor, :browser)
    singleton_class.send(:attr_accessor, :browser_options)
    singleton_class.send(:attr_reader, :descendants)
    @descendants = []

    def initialize(**options)
      @before_tasks = []
      @after_tasks = []
      @options = options

      Task.start_browser
    end

    def self.inherited(subclass)
      Task.descendants << subclass
    end

    def self.find_task(task_symbol)
      Task.descendants.select { |task| task.name.split('::').last.downcase == task_symbol.to_s.downcase }[0]
    end

    def self.start_browser
      if Kinchan.browser_options.nil?
        @@browser_webdriver = Selenium::WebDriver.for Kinchan.browser
      else
        @@browser_webdriver = Selenium::WebDriver.for(Kinchan.browser, options: Kinchan.browser_options)
      end
    end

    def self.restart_browser
      unless @@browser_webdriver.nil?
        @@browser_webdriver.close
        @@browser_webdriver = Selenium::WebDriver.for Kinchan.browser
      end
    end

    def execute(browser); end

    def run
      @before_tasks.each do |task_hash|
        task = Task.find_task(task_hash[:task])
        task.new(**task_hash[:options]).public_send('run') unless task.nil?
      end

      execute(@@browser_webdriver)

      @after_tasks.each do |task_hash|
        task = Task.find_task(task_hash[:task])
        task.new(**task_hash[:options]).public_send('run') unless task.nil?
      end
    end
  end
end

require_all 'tasks' if File.directory?('tasks')
