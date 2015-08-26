defmodule Telephonist.OngoingCallTest do
  use ExUnit.Case
  alias Telephonist.OngoingCall
  doctest Telephonist.OngoingCall

  test ".save can insert a call if its properly formatted" do
    assert :ok == OngoingCall.save({:Sid, "in-progress", %Telephonist.State{}})
  end

  test ".save cannot insert a call if it's improperly formatted" do
    assert {:error, _msg} = OngoingCall.save("SID")
    assert {:error, _msg} = OngoingCall.save({"Sid", nil, nil})
    assert {:error, _msg} = OngoingCall.save({:sid, nil})
  end

  test ".lookup can lookup a call by SID" do
    OngoingCall.save({:Sid, "in-progress", %Telephonist.State{}})
    {:ok, call} = OngoingCall.lookup(:Sid)
    assert call == {:Sid, "in-progress", %Telephonist.State{}}
  end

  test ".lookup returns error if call cannot be found" do
    assert {:error, _msg} = OngoingCall.lookup(:nonexistent)
  end

  test ".lookup returns error if sid is not an atom" do
    assert {:error, _msg} = OngoingCall.lookup("nonexistent")
    assert {:error, _msg} = OngoingCall.lookup({"random", "value"})
  end

  test ".delete removes a call from the table" do
    call = {:DeleteMe, "in-progress", %Telephonist.State{}}
    OngoingCall.save(call)

    # Ensure call is in database
    assert {:ok, call} = OngoingCall.lookup(:DeleteMe)

    # Delete, and try again
    :ok = OngoingCall.delete(call)
    assert {:error, _msg} = OngoingCall.lookup(:DeleteMe)
  end

  test ".delete returns error if isn't passed a valid call or SID" do
    assert {:error, _msg} = OngoingCall.delete("hello")
    assert {:error, _msg} = OngoingCall.delete({:sid, nil})
  end
end
