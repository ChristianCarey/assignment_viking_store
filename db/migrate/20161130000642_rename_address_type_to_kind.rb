class RenameAddressTypeToKind < ActiveRecord::Migration[5.0]
  def change
    rename_column :addresses, :type, :kind
  end
end
