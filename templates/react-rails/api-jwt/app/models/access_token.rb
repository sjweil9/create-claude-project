# Short-lived JWT the SPA sends as `Authorization: Bearer <token>`.
# Stateless: any server instance can verify it with secret_key_base alone,
# which is what makes this approach horizontally scalable with zero shared
# session state. The cost: it can't be revoked before it expires, so keep
# the TTL short and lean on the refresh token for longevity.
module AccessToken
  TTL = 15.minutes
  ALGORITHM = "HS256"

  def self.encode(user)
    JWT.encode(
      { sub: user.id, exp: TTL.from_now.to_i, iat: Time.current.to_i },
      secret,
      ALGORITHM
    )
  end

  # Returns the user id, or nil for a missing/expired/tampered token.
  def self.decode(token)
    payload, = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    payload["sub"]
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    Rails.application.secret_key_base
  end
end
