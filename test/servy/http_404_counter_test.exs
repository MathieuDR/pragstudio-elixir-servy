defmodule Servy.Http404CounterTest do
  use ExUnit.Case

  alias Servy.Http404Counter, as: Counter

  setup do
    SpawnSupport.reset_or_start_server(:counter_server, &Counter.start_link/1, %{"initial" => 2})
    :ok
  end

  describe "bump_count/1" do
    test "counts one" do
      Counter.bump_count("/lassie")
      assert Counter.get_count("/lassie") == 1
    end

    test "counts multiple" do
      Counter.bump_count("/brownie")
      Counter.bump_count("/lissie")
      Counter.bump_count("/lissie")
      assert Counter.get_count("/lissie") == 2
    end
  end

  describe "get_count/0" do
    test "has initial state at start" do
      assert %{"initial" => 2} == Counter.get_counts()
    end

    test "can retrieve multiple" do
      Counter.bump_count("/brownie")
      Counter.bump_count("/lissia")
      Counter.bump_count("/lissia")

      assert %{"/brownie" => 1, "/lissia" => 2} = Counter.get_counts()
    end
  end

  describe "get_count/1" do
    test "returns 0 for non-counted paths" do
      assert Counter.get_count("/oopsie_daisy") == 0
    end

    test "returns counted path" do
      Counter.bump_count("/bloemen")
      Counter.bump_count("/bloemen")
      assert Counter.get_count("/bloemen") == 2
    end
  end

  test "reports counts of missing path requests" do
    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")
    Counter.bump_count("/nessie")
    Counter.bump_count("/bigfoot")
    Counter.bump_count("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert %{"/bigfoot" => 2, "/nessie" => 3} = Counter.get_counts()
  end

  describe "reset/0" do
    test "resets to an empty map" do
      Counter.reset()

      assert %{} == Counter.get_counts()
    end
  end
end
