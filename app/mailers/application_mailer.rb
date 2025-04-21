class ApplicationMailer < ActionMailer::Base
  default from: ENV["GMAIL_USERNAME"] || "kittitatjob@gmail.com"
  layout "mailer"
end
