defmodule SecondAppsWeb.HobbieHTML do
  use SecondAppsWeb, :html

  embed_templates "hobbie_html/*"

  @doc """
  Renders a hobbie form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def hobbie_form(assigns)
end
