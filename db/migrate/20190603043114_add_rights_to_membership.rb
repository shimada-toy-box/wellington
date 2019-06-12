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

class AddRightsToMembership < ActiveRecord::Migration[5.2]
  def up
    add_column :memberships, :can_vote,   :boolean, default: false, null: false
    add_column :memberships, :can_attend, :boolean, default: false, null: false

    # Data migrations for CoNZealand
    {
      "adult"       => { can_attend: true, can_vote: true },
      "young_adult" => { can_attend: true, can_vote: true },
      "unwaged"     => { can_attend: true, can_vote: true },
      "child"       => { can_attend: true, can_vote: false },
      "kid_in_tow"  => { can_attend: true, can_vote: false },
      "supporting"  => { can_attend: false, can_vote: true },
      "supporting+" => { can_attend: false, can_vote: true },
    }.each do |membership_name, rights|
      Membership.where(name: membership_name).update_all(rights)
    end
  end

  def down
    remove_column :memberships, :can_vote
    remove_column :memberships, :can_attend
  end
end