defmodule Telephonist.OngoingCallsTest do
  use ExUnit.Case
  alias Telephonist.OngoingCalls
  doctest Telephonist.OngoingCalls

  ###
  # Public API Tests
  ###

  test "has an ETS table" do
    table = OngoingCalls.table
    assert is_integer(table), "ETS table was not transfered to OngoingCalls"
  end

  test "its ETS table survives even if it crashes" do
    original_table = OngoingCalls.table
    restart_manager

    new_table = OngoingCalls.table
    assert is_integer(new_table), "OngoingCalls was not repopulated with ETS table after reboot"
    assert is_list(:ets.info(new_table))
    assert new_table == original_table, "New OngoingCalls table does not match old"
  end

  test ".save can insert a call if its properly formatted" do
    assert :ok == OngoingCalls.save({:Sid, "in-progress", %Telephonist.State{}})
  end

  test ".lookup can lookup a call by SID" do
    OngoingCalls.save({:Sid, "in-progress", %Telephonist.State{}})
    {:ok, call} = OngoingCalls.lookup(:Sid)
    assert call == {:Sid, "in-progress", %Telephonist.State{}}
  end

  test ".lookup returns {:error, message} if call cannot be found" do
    assert {:error, _msg} = OngoingCalls.lookup(:nonexistent)
  end

  test ".delete removes a call from the table" do
    call = {:DeleteMe, "in-progress", %{}}
    OngoingCalls.save(call)

    # Ensure call is in database
    assert {:ok, call} = OngoingCalls.lookup(:DeleteMe)

    # Delete, and try again
    :ok = OngoingCalls.delete(call)
    assert {:error, _msg} = OngoingCalls.lookup(:DeleteMe)
  end

  ###
  # Helpers
  ###

  defp restart_manager do
    pid = Process.whereis(OngoingCalls)
    Process.exit(pid, :normal)
    OngoingCalls.start_link
  end
end
