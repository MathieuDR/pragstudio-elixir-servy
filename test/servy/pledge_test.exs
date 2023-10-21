defmodule Servy.PledgeTest do
  use ExUnit.Case

  alias Servy.Pledges

  setup do
    Process.whereis(:pledge_server)
    |> case do
      nil ->
        :ok

      pid ->
        Process.unregister(:pledge_server)
        Process.exit(pid, :kill)
    end

    Pledges.start([{"Thieu", 200}, {"Shooki", 100}, {"Vreemden", 50}, {"Blieken", 25}])
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
end
