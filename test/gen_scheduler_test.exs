defmodule GenSchedulerTest do
  use ExUnit.Case, async: true
  doctest GenScheduler

  test "schedule_jobs gets called when schedule_now? returns :ok" do
    test_pid = self()

    defmodule TestScheduler do
      @test_pid test_pid
      def schedule_now?(), do: :ok

      def schedule_jobs() do
        send(@test_pid, :job_enqueued)
        IO.inspect({:ok, []})
      end
    end

    GenScheduler.start_link(TestScheduler)

    assert_receive(:job_enqueued)
  end
end
