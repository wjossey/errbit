require 'ostruct'

Errbit::Config = OpenStruct.new

# If Errbit is running on Heroku, config can be set from environment variables.
if ENV['HEROKU']
  Errbit::Config.host = ENV['ERRBIT_HOST']
  Errbit::Config.email_from = ENV['ERRBIT_EMAIL_FROM']
  Errbit::Config.email_at_notices = [1,3,10] #ENV['ERRBIT_EMAIL_AT_NOTICES']
  Errbit::Config.confirm_resolve_err = ENV['ERRBIT_CONFIRM_RESOLVE_ERR']

  Errbit::Config.smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => ENV['SENDGRID_DOMAIN']
  }
end

# Use example config for test environment.
config_file = Rails.root.join('config', Rails.env == "test" ? "config.example.yml" : "config.yml")

# Load config if config file exists.
if File.exists?(config_file)
  yaml = File.read(config_file)
  config = YAML.load(yaml)
  config.merge!(config.delete(Rails.env)) if config.has_key?(Rails.env)
  config.each do |k,v|
    Errbit::Config.send("#{k}=", v)
  end
# Raise an error if we are not running tests, not running on Heroku, and config.yml doesn't exist.
elsif not ENV['HEROKU']
  raise "Please copy 'config/config.example.yml' to 'config/config.yml' and configure your settings."
end

# Set SMTP settings if given.
if smtp = Errbit::Config.smtp_settings
  Errbit::Application.config.action_mailer.smtp_settings = smtp
end

# Set config specific values
(Errbit::Application.config.action_mailer.default_url_options ||= {}).tap do |default|
  default.merge! :host => Errbit::Config.host if default[:host].blank?
end

