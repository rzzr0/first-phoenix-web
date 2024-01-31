defmodule SecondAppsWeb.KejuaraanHTML do
  use SecondAppsWeb, :html

  embed_templates "kejuaraan_html/*"

  @doc """
  Renders a kejuaraan form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def kejuaraan_form(assigns)
end
