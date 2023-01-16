defmodule Servy.UserApi do
  def query(id) do
    get_url(id)
    |> send_request()
    |> handle_response()
  end

  def get_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  def send_request(url) do
    HTTPoison.get(url)
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    city =
      Poison.Parser.parse!(body, %{})
      |> get_in(["address", "city"])

    {:error, city}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: _status_code, body: body}}) do
    reason =
      Poison.Parser.parse!(body, %{})
      |> get_in(["message"])

    {:error, reason}
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
