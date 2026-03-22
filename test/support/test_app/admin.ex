defmodule AdminKit.TestApp.Admin do
  use AdminKit, otp_app: :admin_kit

  admin_resource AdminKit.TestApp.User do
    context AdminKit.TestApp.Accounts
    index_fields [:name, :email, :role, :inserted_at]
    form_fields [:name, :email, :role]
    field :role, type: :select, choices: [:admin, :editor, :viewer]
    scope :all, default: true
    scope :admins, filter: fn q -> import Ecto.Query; where(q, [u], u.role == :admin) end
    action :confirm, label: "Confirm", handler: &AdminKit.TestApp.Accounts.confirm_user/1
    searchable_fields [:name, :email]
  end

  admin_resource AdminKit.TestApp.Product do
    context AdminKit.TestApp.Catalog
    index_fields [:title, :price, :active]
    form_fields [:title, :description, :price, :active]
    field :active, type: :boolean
    scope :all, default: true
    scope :active, filter: fn q -> import Ecto.Query; where(q, [p], p.active == true) end
    searchable_fields [:title]
  end
end
