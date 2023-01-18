defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounter, as: Counter

  test "reports counts of missing path requests" do
    Counter.start()

    Counter.count_404("/bigfoot")
    Counter.count_404("/nessie")
    Counter.count_404("/nessie")
    Counter.count_404("/bigfoot")
    Counter.count_404("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert Counter.get_counts() == %{"/bigfoot" => 2, "/nessie" => 3}
  end
end
