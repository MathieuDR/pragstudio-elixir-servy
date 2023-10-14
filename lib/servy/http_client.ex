defmodule Servy.HttpClient do
  def client(address, port) do
    {:ok, socket} =
      :gen_tcp.connect(address |> String.to_charlist(), port, [
        :binary,
        packet: :raw,
        active: false
      ])

    socket
  end

  def send_request(socket, content) do
    :gen_tcp.send(socket, content)
    :gen_tcp.recv(socket, 0)
  end

  def close_client(socket), do: :gen_tcp.close(socket)

  def send_and_forget(address, port, content) do
    client = client(address, port)
    response = send_request(client, content)
    close_client(client)
    response
  end
end
