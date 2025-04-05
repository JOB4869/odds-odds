require "solid_queue"

SolidQueue::Record.connects_to database: { writing: :primary }
