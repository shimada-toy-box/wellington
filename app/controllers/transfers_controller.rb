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

#
class TransfersController < ApplicationController
  helper PurchasesHelper

  before_action :assert_support!

  def new
    @purchase = Purchase.find(params[:purchase_id])
    @detail = @purchase.active_claim.detail
  end

  def show
    @transfer = Purchase::PlanTransfer.new(
      new_owner: params[:id],
      purchase_id: params[:purchase_id],
    )
  end

  def create
  end
end
