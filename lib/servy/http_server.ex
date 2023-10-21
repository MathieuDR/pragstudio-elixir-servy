defmodule Servy.HttpServer do
  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections.
    # `listen_socket` is bound to the listening socket.
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # Socket options (don't worry about these details):
    # `:binary` - open the socket in "binary" mode and deliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`.
  """
  def accept_loop(listen_socket) do
    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    # Receives the request and sends a response over the client socket.
    pid = spawn(fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    # Loop back to wait and accept the next connection.
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket) do
    client_socket
    |> read_request
    # |> generate_response
    |> Servy.Handler.handle()
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the `client_socket`.
  """
  def read_request(client_socket) do
    # all available bytes
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    request
  end

  @doc """
  Sends the `response` over the `client_socket`.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    # Closes the client socket, ending the connection.
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end
end
