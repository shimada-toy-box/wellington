# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

class Token::LookupOrCreateUser
  attr_reader :token
  attr_reader :secret

  def initialize(token:, secret:)
    @token = token
    @secret = secret
  end

  def call
    check_token
    check_secret

    decode_token
    return false if errors.any?

    lookup_and_validate_user
    return false if errors.any?

    @user
  end

  def errors
    @errors ||= []
  end

  private

  def check_token
    if !token.present?
      errors << "missing token"
    end
  end

  def check_secret
    if !secret.present?
      errors << "cannot decode without secret"
    end
  end

  def decode_token
    @token = JWT.decode(token, secret, "HS256")
  rescue JWT::ExpiredSignature
    errors << "token has expired"
  rescue JWT::DecodeError
    errors << "token is malformed"
  end

  def lookup_and_validate_user
    @user = User.find_or_create_by(email: @token.first["email"])
    if !@user.valid?
      @user.errors.full_messages.each do |validation_error|
        errors << validation_error
      end
    end
  end
end