defmodule Servy.Recurse do
  def loopy([head | tail], num) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    num = num + head
    loopy(tail, num)
  end

  def loopy([], num), do: num

  def triple([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")

    triple = head * 3

    [triple | triple(tail)]
  end

  def triple([]), do: []
end

num = Servy.Recurse.loopy([1, 2, 3, 4, 5], 0)

IO.inspect(num)
