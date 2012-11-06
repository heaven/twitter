module Enumerable

  def threaded_map
    twitter_abort_on_exception do
      threads = []
      each do |object|
        threads << Thread.new { twitter_handle_exception(threads) { yield object } }
      end
      threads.map(&:value)
    end
  end

  private

  def twitter_abort_on_exception
    initial_abort_on_exception = Thread.abort_on_exception
    Thread.abort_on_exception = false
    value = yield
    Thread.abort_on_exception = initial_abort_on_exception
    value
  end

  def twitter_handle_exception(threads, &block)
    yield
  rescue => e
    threads.find_all { |t| t != Thread.current }.map(&:kill)
    raise e
  end

end
