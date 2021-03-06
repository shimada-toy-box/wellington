# frozen_string_literal: true

# Copyright 2018 Andrew Esler
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

class PaymentField < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  self.table_name = "payment_fields"
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
