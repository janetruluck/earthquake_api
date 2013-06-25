# import Job
class ImportJob
  @queue = :import

  def self.perform(wait_time)
    # wait 1 minute to run, this can be
    # improved by using resque_scheduler or cron
    sleep(wait_time.minute)
    # Schedule a new job
    Resque.enqueue(ImportJob)
    # Import new data
    Earthquake.import
  end
end
