defmodule Servy.Conv do
  @moduledoc """
  The conversation for Servy
  """

  @type t() :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          resp_body: String.t(),
          status_code: non_neg_integer() | nil,
          headers: [],
          params: %{} | nil,
          resp_content_type: String.t()
        }

  defstruct method: "",
            path: "",
            resp_body: "",
            status_code: nil,
            headers: [],
            params: %{},
            resp_content_type: "text/html"
end
