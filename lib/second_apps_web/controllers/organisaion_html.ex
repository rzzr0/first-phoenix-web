defmodule SecondAppsWeb.OrganisaionHTML do
  use SecondAppsWeb, :html

  embed_templates "organisaion_html/*"

  @doc """
  Renders a organisaion form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def organisaion_form(assigns)
end
