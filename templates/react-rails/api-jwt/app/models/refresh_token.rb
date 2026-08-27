# A refresh token is a long-lived, single-use credential. Only a SHA-256
# digest is stored — a database leak doesn't yield usable tokens. (SHA-256,
# not bcrypt, because we must look tokens up by value; the input is 256 bits
# of randomness, so brute-forcing the digest is not a concern.)
class RefreshToken < ApplicationRecord
  TTL = 30.days

  belongs_to :user

  scope :active, -> { where(revoked_at: nil).where(expires_at: Time.current..) }

  # Returns [record, raw_token]; the raw value goes in the httpOnly cookie and
  # is never persisted.
  def self.issue_for(user)
    raw = SecureRandom.hex(32)
    record = user.refresh_tokens.create!(
      token_digest: digest(raw),
      expires_at: TTL.from_now
    )
    [record, raw]
  end

  def self.find_by_raw(raw)
    find_by(token_digest: digest(raw)) if raw.present?
  end

  def self.digest(raw)
    Digest::SHA256.hexdigest(raw)
  end

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
