defmodule Telephonist.OngoingCallTest do
  use ExUnit.Case
  alias Telephonist.OngoingCall
  doctest Telephonist.OngoingCall

  test "has an ETS table" do
    table = OngoingCall.table
    assert is_integer(table), "ETS table was not transfered to OngoingCall"
  end

  test "its ETS table survives even if it crashes" do
    original_table = OngoingCall.table
    restart_manager

    new_table = OngoingCall.table
    assert is_integer(new_table), "OngoingCall was not repopulated with ETS table after reboot"
    assert is_list(:ets.info(new_table))
    assert new_table == original_table, "New OngoingCall table does not match old"
  end

  test ".save can insert a call if its properly formatted" do
    assert :ok == OngoingCall.save({:Sid, "in-progress", %Telephonist.State{}})
  end

  test ".lookup can lookup a call by SID" do
    OngoingCall.save({:Sid, "in-progress", %Telephonist.State{}})
    {:ok, call} = OngoingCall.lookup(:Sid)
    assert call == {:Sid, "in-progress", %Telephonist.State{}}
  end

  test ".lookup returns {:error, message} if call cannot be found" do
    assert {:error, _msg} = OngoingCall.lookup(:nonexistent)
  end

  test ".delete removes a call from the table" do
    call = {:DeleteMe, "in-progress", %{}}
    OngoingCall.save(call)

    # Ensure call is in database
    assert {:ok, call} = OngoingCall.lookup(:DeleteMe)

    # Delete, and try again
    :ok = OngoingCall.delete(call)
    assert {:error, _msg} = OngoingCall.lookup(:DeleteMe)
  end

  ###
  # Helpers
  ###

  defp restart_manager do
    pid = Process.whereis(OngoingCall)
    Process.exit(pid, :normal)
    OngoingCall.start_link
  end
end
