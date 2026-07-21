# frozen_string_literal: true

# Each time a record is set we check whether its session has already timed out
# or not, based on last request time. If so, the record is logged out and
# redirected to the sign in page. Also, each time the request comes and the
# record is set, we set the last request time inside its scoped session to
# verify timeout in the following request.
#
# When an absolute (maximum) session length is configured, the time the session
# started is also stored and used to log the record out once that length is
# reached, regardless of activity.
Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]
  env   = warden.request.env

  if record && record.respond_to?(:timedout?) && warden.authenticated?(scope) &&
     options[:store] != false && !env['devise.skip_timeoutable']
    session = warden.session(scope)

    parse_time = lambda do |value|
      case value
      when Integer then Time.at(value).utc
      when String  then Time.parse(value)
      else value
      end
    end

    last_request_at    = parse_time.call(session['last_request_at'])
    session_created_at = parse_time.call(session['session_created_at']) || last_request_at

    proxy = Devise::Hooks::Proxy.new(warden)

    if !env['devise.skip_timeout'] &&
        (record.timedout?(last_request_at) || record.session_expired?(session_created_at)) &&
        !proxy.remember_me_is_active?(record)
      Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)
      throw :warden, scope: scope, message: :timeout, locale: options.fetch(:locale, I18n.locale)
    end

    unless env['devise.skip_trackable']
      session['last_request_at']    = Time.now.utc.to_i
      session['session_created_at'] ||= Time.now.utc.to_i
    end
  end
end
