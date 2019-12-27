# frozen_string_literal: true

require 'kinchan/version'
require 'selenium-webdriver'
require 'require_all'

module Kinchan
  class Error < StandardError; end

  class Task
    singleton_class.send(:attr_accessor, :browser)
    singleton_class.send(:attr_accessor, :browser_options)
    singleton_class.send(:attr_reader, :descendants)
    @descendants = []
    @browser = :chrome
    @browser_options = nil
    @@browser_webdriver = nil

    def initialize(**options)
      @before_tasks = []
      @after_tasks = []
      @options = options
    end

    def self.inherited(subclass)
      Task.descendants << subclass
    end

    def self.find_task(task_symbol)
      Task.descendants.select { |task| task.name.split('::').last.downcase == task_symbol.to_s.downcase }[0]
    end

    def self.restart_browser
      unless @@browser_webdriver.nil?
        @@browser_webdriver.close
        @@browser_webdriver = Selenium::WebDriver.for Task.browser
      end
    end

    def execute(browser); end

    def run
      if @@browser_webdriver.nil?
        if Task.browser_options.nil?
          @@browser_webdriver = Selenium::WebDriver.for Task.browser
        else
          @@browser_webdriver = Selenium::WebDriver.for(Task.browser, options: Task.browser_options)
        end
      end

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

require_all 'tasks'
