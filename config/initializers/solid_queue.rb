
SolidQueue.configure do |config|
  config.connects_to = {
    database: {
      writing: :queue,
      reading: :queue
    }
  }
end
