defmodule GenericServer do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        loop(state, callback_module)

      {:cast, message} ->
        state = callback_module.handle_cast(message, state)
        loop(state, callback_module)

      message ->
        state = callback_module.handle_info(message, state)
        loop(state, callback_module)
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    after
      5000 -> :error
    end
  end
end
