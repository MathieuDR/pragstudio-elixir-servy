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
          resp_headers: %{}
        }

  defstruct method: "",
            path: "",
            resp_body: "",
            status_code: nil,
            headers: [],
            params: %{},
            resp_headers: %{}

  def put_content(
        %__MODULE__{resp_headers: headers} = conv,
        content,
        type \\ "text/html",
        status_code \\ 200
      ) do
    headers =
      headers
      |> Map.put("Content-Type", type)
      |> Map.put("Content-Length", byte_size(content))

    %{conv | resp_headers: headers, resp_body: content, status_code: status_code}
  end
end
