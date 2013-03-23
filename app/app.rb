require 'auto_locale'
require 'will_paginate/active_record'
require "padrino/pundit"

class Downthemall < Padrino::Application
  use ActiveRecord::ConnectionAdapters::ConnectionManagement
  use Rack::Protection

  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register WillPaginate::Sinatra
  register Padrino::Sprockets
  register StraightAuth
  register AutoLocale
  register Padrino::Pundit

  sprockets minify: (Padrino.env == :production)

  set :locales, [:en, :it, :de]

  enable :sessions

  module Helpers
    include BasicPresenter::Helpers
  end

  helpers do
    include Helpers

    def authorized?(record, action)
      Pundit.policy!(current_user, record).send("#{action}?")
    end

    alias_method :authorize!, :authorize
  end

  configure :development, :test do
    set :host, "http://downthemall.dev"
    set :paypal_account, "vendo_1321197264_biz@gmail.com"
    set :paypal_url, "https://www.sandbox.paypal.com/cgi-bin/webscr"
    ActiveMerchant::Billing::Base.mode = :test
  end

  configure :development do
    set :delivery_method, LetterOpener::DeliveryMethod
    Mail.defaults do
      delivery_method LetterOpener::DeliveryMethod, location: File.expand_path('../tmp/letter_opener', __FILE__)
    end

    error do
      exception = env['sinatra.error']
      CGI::escapeHTML(exception.message) + "<br/>"*2 + exception.backtrace.join("<br/>")
    end
  end

  configure :test do
    set :delivery_method, :test
  end

  configure :production do
    set :host, "http://www.downthemall.net"
    set :paypal_account, "donors@downthemall.net"
    set :paypal_url, "https://www.paypal.com/cgi-bin/webscr"
  end

  error StraightAuth::AuthenticatedUserRequired do
    flash[:alert] = I18n.t('authentication.must_be_signed_in')
    redirect url(:index)
  end

  error StraightAuth::UnauthenticatedUserRequired do
    flash[:alert] = I18n.t('authentication.already_signed_in')
    redirect url(:index)
  end

  error Pundit::NotAuthorizedError do
    flash[:alert] = I18n.t('authorization.forbidden')
    redirect url(:index)
  end

  set :show_exceptions, false
end
