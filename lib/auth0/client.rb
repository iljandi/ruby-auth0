# Main class
# All Api calls are suposed to return hashes, but delete actions return strings.
class Auth0::Client
  include Auth0::Mixins
  include HTTParty
  base_uri 'http://auth0.com'

  def register_user(options)
    response = self.class.post(
      '/api/users/',
      body:
        {
          email: options.fetch(:email),
          password: options.fetch(:password),
          connection: options.fetch(:connection),
          email_verified: options.fetch(:email_verified),
          two_factor: options.fetch(:two_factor)
        }.to_json
    )

    if response.code == 200
      response.body
    else
      fail Auth0::Exception, response.body
    end
  end

  def fetch_auth_id_for(email)
    user = find_user(email)
    user.try(:[], 0).try(:[], 'user_id')
  end

  def find_user(email)
    uri = URI.escape("/api/users?search=email:#{email}")
    response = self.class.get(uri)
    JSON.parse(response.body)
  end

  def update_user_metadata(id, options)
    update_user(:metadata, id, options)
  end

  def update_user_password(id, password, verify = true)
    update_user(:password, id, password: password, verify: verify)
  end

  def update_user_email(id, email, verify = true)
    update_user(:email, id, email: email, verify: verify)
  end

  def update_user_two_factor(id, value)
    update_user(:metadata, id, { two_factor: value }, :patch)
  end

  def update_user(type, id, options, method = :put)
    uri = URI.escape("/api/users/#{id}/#{type}")
    response = self.class.send(method, uri, body: options.to_json)

    if response.code == 200
      response.body
    else
      fail Auth0::Exception, response.body
    end
  end
end
