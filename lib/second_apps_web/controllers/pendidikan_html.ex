defmodule SecondAppsWeb.PendidikanHTML do
  use SecondAppsWeb, :html

  embed_templates "pendidikan_html/*"

  @doc """
  Renders a pendidikan form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def pendidikan_form(assigns)
end
