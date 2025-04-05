# require "solid_queue"

# SolidQueue.configure do |config|
# end
SolidQueue::Record.connects_to database: { writing: :primary }
