namespace :resque do
  desc "Looks up all pids from all Resque workers and send them a QUIT signal."
  task :quit_workers => :environment do
    pids = Array.new

    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end

    system("kill -QUIT #{pids.join(' ')}") unless pids.empty?
    puts "Stopped #{pids.size} process(s)."
  end
end