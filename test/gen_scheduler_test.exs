defmodule GenSchedulerTest do
  use ExUnit.Case, async: true
  doctest GenScheduler

  test "schedule_jobs gets called when schedule_now? returns :ok" do
    test_pid = self()

    schedulable =
      Promox.new()
      |> Promox.stub(GenScheduler.Schedulable, :schedule_now?, fn _ -> :ok end)
      |> Promox.expect(
        GenScheduler.Schedulable,
        :schedule_jobs,
        fn _ ->
          send(test_pid, :job_enqueued)
          {:ok, []}
        end
      )

    GenScheduler.start_link(schedulable)

    assert_receive(:job_enqueued)
  end
end
