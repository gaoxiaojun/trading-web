module Rake
  module TaskManager
    def redefine_task(task_class, args, &block)
      task_name, deps = resolve_args([args])
      task_name = task_class.scope_name(@scope, task_name)
      deps = [deps] unless deps.respond_to?(:to_ary)
      deps = deps.collect {|d| d.to_s }
      task = @tasks[task_name.to_s] = task_class.new(task_name, self)
      task.application = self
      task.add_description(@last_description)
      @last_description = nil
      task.enhance(deps, &block)
      task
    end
  end
  class Task
    
    class << self
      def redefine_task(args, &block)
        Rake.application.redefine_task(self, args, &block)
      end
    end
    
    def remove_prerequisite(task_name)
      name = task_name.to_s
      @prerequisites.delete(name)
    end
    
  end
end

def redefine_task(args, &block)
  Rake::Task.redefine_task(args, &block)
end

#Rake::Task['test:units'].remove_prerequisite('db:test:prepare')
#Rake::Task['test:functionals'].remove_prerequisite('db:test:prepare')