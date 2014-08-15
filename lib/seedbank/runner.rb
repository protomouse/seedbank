module Seedbank
  class Runner < Module
  
    def initialize(task)
      @task = task
      super()
    end

    # Run this seed after the specified dependencies have run
    # @param dependencies [Array] seeds to run before the block is executed
    # 
    # If a block is specified the contents of the block are executed after all the
    # dependencies have been executed.
    #
    # If no block is specified just the dependencies are run. This makes it possible
    # to create shared dependencies. For example
    #
    # @example db/seeds/production/users.rb
    #   after 'shared:users'
    #
    # Would look for a db/seeds/shared/users.rb seed and execute it.
    def after(*dependencies, &block)
      dependencies.flatten!
      dependencies.map! { |dep| "db:seed:#{dep}"}
      dependent_task_name =  @task.name + ':body'

      # Only define the dependent task the first time through
      dependent_task = Rake.application.lookup(dependent_task_name)
      unless dependent_task
        dependent_task = Rake::Task.define_task(dependent_task_name => dependencies, &block)
      end

      dependent_task.invoke
    end
  
  end
end
