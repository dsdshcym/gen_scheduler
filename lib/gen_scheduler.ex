defmodule GenScheduler do
  @moduledoc """
  Documentation for `GenScheduler`.
  """

  defprotocol Schedulable do
    @type job :: struct()

    @spec schedule_now?(t()) :: :ok | :not_now
    def schedule_now?(schedulable)

    @spec schedule_jobs(t()) :: {:ok, [job]} | {:error, any()}
    def schedule_jobs(schedulable)
  end

  defimpl Schedulable, for: Atom do
    def schedule_now?(mod), do: mod.schedule_now?()
    def schedule_jobs(mod), do: mod.schedule_jobs()
  end

  def start_link(schedulable) do
    GenServer.start_link(__MODULE__, schedulable)
  end

  use GenServer

  def init(schedulable) do
    send(self(), :schedule)
    {:ok, %{schedulable: schedulable, timer: nil}}
  end

  def handle_info(:schedule, %{timer: timer, schedulable: schedulable} = state) do
    if timer, do: Process.cancel_timer(timer)

    timer =
      with :ok <- Schedulable.schedule_now?(schedulable),
           {:ok, _jobs} <- Schedulable.schedule_jobs(schedulable) do
        Process.send_after(self(), :schedule, 0)
      else
        _ ->
          Process.send_after(self(), :schedule, 10)
      end

    {:noreply, %{state | timer: timer}}
  end
end
