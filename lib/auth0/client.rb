# Main class
# All Api calls are suposed to return hashes, but delete actions return strings.
class Auth0::Client
  include Auth0::Mixins
  include HTTParty
  base_uri 'http://auth0.com'

  def register_user(options)
    response = self.class.post(
       '/api/v2/users',
      body:
        {
          email: options.fetch(:email),
          password: options.fetch(:password),
          connection: options.fetch(:connection),
          email_verified: options.fetch(:email_verified),
          app_metadata: { two_factor: options.fetch(:two_factor) }
        }.to_json
    )

    if response.code == 201
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
    uri = URI.escape('/api/v2/users?q=email:"' + email + '"&search_engine=v2')
    response = self.class.get(uri)
    JSON.parse(response.body)
  end

  def update_user_metadata(id, options)
    update_user(:id, { app_metadata: options } )
  end

  def update_user_password(id, password, verify = true)
    update_user(id, password: password, verify_password: verify)
  end

  def update_user_email(id, email, verify = true)
    update_user(id, email: email, verify_email: verify)
  end

  def update_user_two_factor(id, value)
    update_user(id, { app_metadata: { two_factor: value }}, :patch)
  end

  def update_user(id, options, method = :patch)
    uri = URI.escape("/api/v2/users/#{id}")
    response = self.class.send(method, uri, body: options.to_json)

    if response.code == 200
      response.body
    else
      fail Auth0::Exception, response.body
    end
  end
end
