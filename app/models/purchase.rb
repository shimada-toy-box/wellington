# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

class Purchase < ApplicationRecord
  ACTIVE = "active"
  DISABLED = "disabled"
  INSTALLMENT = "installment"

  has_many :charges
  has_many :claims
  has_many :orders

  # See Order's validations for :purchase, only one order active at a time
  has_one :active_order, ->() { active }, class_name: "Order"
  has_one :product, through: :active_order

  # See Claim's validations for :purchase, only one claim active at a time
  has_one :active_claim, -> () { active }, class_name: "Claim"
  has_one :user, through: :active_claim

  # TODO inclusion in prices and presupport price options
  validates :level, presence: true
  validates :state, presence: true, inclusion: [ACTIVE, INSTALLMENT, DISABLED]
  validates :worth, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def transferable?
    state == ACTIVE && !Product::PRESUPPORT_PRICES.has_key?(level)
  end
end
