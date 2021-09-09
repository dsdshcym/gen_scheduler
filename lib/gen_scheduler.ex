defmodule GenScheduler do
  @moduledoc """
  Documentation for `GenScheduler`.
  """

  @type job :: struct()
  @callback schedule_now?() :: :ok | :not_now
  @callback schedule_jobs() :: {:ok, [job]} | {:error, any()}

  def start_link(mod) do
    GenServer.start_link(__MODULE__, mod)
  end

  use GenServer

  def init(mod) do
    send(self(), :schedule)
    {:ok, %{mod: mod, timer: nil}}
  end

  def handle_info(:schedule, %{timer: timer, mod: mod} = state) do
    if timer, do: Process.cancel_timer(timer)

    timer =
      with :ok <- mod.schedule_now?(),
           :ok <- mod.schedule_jobs() do
        Process.send_after(self(), :schedule, 0)
      else
        _ ->
          Process.send_after(self(), :schedule, 10)
      end

    {:noreply, %{state | timer: timer}}
  end
end
