defmodule GenSchedulerTest do
  use ExUnit.Case
  doctest GenScheduler

  import Mox
  setup :set_mox_from_context

  test "schedule_jobs gets called when schedule_now? returns :ok" do
    Mox.stub(TestScheduler, :schedule_now?, fn -> :ok end)

    test_pid = self()

    Mox.expect(TestScheduler, :schedule_jobs, fn ->
      send(test_pid, :job_enqueued)
      {:ok, []}
    end)

    GenScheduler.start_link(TestScheduler)

    assert_receive(:job_enqueued)
  end
end
