defmodule Servy.PledgeTest do
  use ExUnit.Case

  alias Servy.Pledges

  setup do
    SpawnSupport.reset_or_start_server(:pledge_server, &Pledges.start_link/1, %Pledges.State{
      pledges: [
        {"Thieu", 200},
        {"Shooki", 100},
        {"Vreemden", 50}
      ]
    })

    :ok
  end

  test "get_pledges/0 only returns 3 pledges" do
    assert {:ok, [_first, _second, _third]} = Pledges.get_pledges()
  end

  test "create_pledge/2 returns an ID" do
    assert {:ok, "pledge-" <> _id} = Pledges.create_pledge("My pledge", 25)
  end

  test "total_pledges/0 totals all pledges" do
    assert {:ok, 375} = Pledges.total_pledged()
  end

  test "set_cache_size/1 changes amount of pledges" do
    Pledges.set_cache_size(4)
    assert {:ok, pledges} = Pledges.get_pledges()
    assert 4 == Enum.count(pledges)
  end
end
