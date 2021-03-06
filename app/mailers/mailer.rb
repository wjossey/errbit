# Haml doesn't load routes automatically when called via a rake task.
# This is only necessary when sending test emails (i.e. from rake hoptoad:test)
require Rails.root.join('config/routes.rb')

class Mailer < ActionMailer::Base
  include InlineCss

  default :from => Errbit::Config.email_from

  def err_notification(notice)
    @notice   = notice
    @app  = notice.err.app

    mail({
      :to       => @app.notification_recipients,
      :subject  => "[#{@app.name}][#{@notice.err.environment}] #{@notice.err.message}"
    })
  end

  def deploy_notification(deploy)
    @deploy   = deploy
    @app  = deploy.app

    mail({
      :to       => @app.notification_recipients,
      :subject  => "[#{@app.name}] Deployed to #{@deploy.environment} by #{@deploy.username}"
    })
  end

end

