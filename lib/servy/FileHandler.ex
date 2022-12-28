defmodule Servy.FileHandler do

@spec handle_file({:error, any} | {:ok, any}, %{
         :resp_body => any,
         :status => any,
         optional(any) => any
       }) :: %{:resp_body => any, :status => 200 | 404 | 500, optional(any) => any}


  def handle_file({:ok, content}, conv) do
      %{conv | status: 200, resp_body: content}
 end

 def handle_file({:error, :enoent}, conv) do
      %{conv | status: 404, resp_body: "File not found"}
 end

 def handle_file({:error, reason}, conv) do
      %{conv| status: 500, resp_body: "Error: #{reason}"}
 end

end
