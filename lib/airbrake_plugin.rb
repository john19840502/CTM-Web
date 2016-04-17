require 'airbrake'
require 'delayed_job'
 
class AirbrakePlugin < Delayed::Plugin
 
  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, *args, &block|
      begin
        # Forward the call to the next callback in the callback chain
        block.call(job, *args)
      rescue Exception => error
        ::Airbrake.notify_or_ignore(
            :error_class   => error.class.name,
            :error_message => "#{error.class.name}: #{error.message}",
            :backtrace => error.backtrace,
            :parameters    => {
                :failed_job => job.inspect
            }
        )
        # Make sure we propagate the failure!
        raise error
      end
    end
  end
 
end