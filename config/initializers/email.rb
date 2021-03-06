# frozen_string_literal: true

# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Rails.application.config.action_mailer.tap do |action_mailer|
  if Rails.env.development?
    # Advice from rails g devise:install
    action_mailer.default_url_options = { host: "localhost", port: 3000 }

    # hook into mailcatcher
    action_mailer.delivery_method = :smtp
    inside_docker = File.exist?("/.dockerenv")
    if inside_docker
      # mailcatcher running in another container defined in docker-compose.yml
      action_mailer.smtp_settings = { address: "mail", port: 1025 }
    else
      # mailcatcher running in backgrounded process
      action_mailer.smtp_settings = { address: "0.0.0.0", port: 1025 }
    end


    # Mailer previews for rspec
    # see https://stackoverflow.com/a/39204340/81271
    # preview on http://localhost:3000/rails/mailers
    action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
  elsif Rails.env.test?
    action_mailer.default_url_options = {
      host: "localhost"
    }
  else
    # Setup SMTP
    # https://guides.rubyonrails.org/action_mailer_basics.html
    action_mailer.delivery_method = :smtp
    action_mailer.tap do |action_mailer|
      action_mailer.raise_delivery_errors = true
      action_mailer.smtp_settings = {
        address:              ENV["SMTP_SERVER"],
        port:                 ENV["SMTP_PORT"],
        user_name:            ENV["SMTP_USER_NAME"],
        password:             ENV["SMTP_PASSWORD"],
        authentication:       "plain",
        enable_starttls_auto: true,
        ssl:                  ENV["SMTP_PORT"].to_i == 465
      }
    end
  end

  if Rails.env.production?
    %w(MAINTAINER_EMAIL MEMBER_SERVICES_EMAIL HUGO_HELP_EMAIL).each do |env_var|
      begin
        puts "Please set #{env_var} in production"
        exit 1
      end unless ENV[env_var].present?
    end
  end

  #FIXME by adding the correct email addresses before this goes into production
  $maintainer_email = ENV.fetch(
    "MAINTAINER_EMAIL",
    "maintainer@localhost"
  ).downcase

  $member_services_email = ENV.fetch(
    "MEMBER_SERVICES_EMAIL",
    "member_services@localhost"
  ).downcase

  # FIXME I know this is a lousy hack. I plan to revisit the emails soon and make a con-config setup for them.
  $treasurer_email = ENV.fetch(
    "TREASURER_EMAIL",
    "treasurer@chicon.org"
  ).downcase

  $hugo_help_email = ENV.fetch(
    "HUGO_HELP_EMAIL",
    "hugo_help@localhost"
  ).downcase

  if Rails.env.production? && ENV["HUGO_HELP_EMAIL"].nil?
    puts "Please set HUGO_HELP_EMAIL to allow for reply address on report emails"
    exit 1
  end

  # If these are not set, they're basically disabled
  $nomination_reports_email = ENV["NOMINATION_REPORTS_EMAIL"]&.downcase
  $membership_reports_email = ENV["MEMBERSHIP_REPORTS_EMAIL"]&.downcase
end
