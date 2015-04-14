defmodule Telephonist.CallTrackerTest do
  use ExUnit.Case
  alias Telephonist.CallTracker

  test "has an ETS table" do
    table = CallTracker.table
    assert is_integer(table), "ETS table was not transfered to CallTracker"
  end

  test "its ETS table survives even if it crashes" do
    original_table = CallTracker.table
    restart_tracker

    new_table = CallTracker.table
    assert is_integer(new_table), "CallTracker was not repopulated with ETS table after reboot"
    assert is_list(:ets.info(new_table))
    assert new_table == original_table, "New CallTracker table does not match old"
  end

  defp restart_tracker do
    pid = Process.whereis(CallTracker)
    Process.exit(pid, :normal)
    CallTracker.start_link
  end
end
