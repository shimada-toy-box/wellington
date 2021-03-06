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

# Autogenerated from rails app:update
# This migration comes from active_storage (originally 20180723000244)
class AddForeignKeyConstraintToActiveStorageAttachmentsForBlobId < ActiveRecord::Migration[6.0]
  def up
    return if foreign_key_exists?(:active_storage_attachments, column: :blob_id)

    if table_exists?(:active_storage_blobs)
      add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    end
  end
end
