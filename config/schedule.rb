# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# set :output, "~/Work/Biu/tmp/log/cron_log.log"
set :output, "~/logs/cron_log.log"

job_type :rbenv_rake, %Q{export PATH=~/.rbenv/shims:~/.rbenv/bin:/usr/local/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
                         cd :path && :environment_variable=:environment bundle exec rake :task --silent :output }

every 1.minute do
    rbenv_rake "biu:match"
end

every 1.day, :at => '3:00 am' do
    rbenv_rake "biu:scan_user"
end

# Learn more: http://github.com/javan/whenever
