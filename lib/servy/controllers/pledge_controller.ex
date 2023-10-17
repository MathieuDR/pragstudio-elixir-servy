defmodule Servy.Controllers.PledgeController do
  def create(conv, %{"name" => name, "amount" => amount}) do
    Servy.Pledges.create_pledge(name, String.to_integer(amount))
    Servy.Conv.put_content(conv, "#{name} pledged #{amount}€")
  end

  def index(conv) do
    pledges = Servy.Pledges.get_pledget()
    Servy.Conv.put_content(conv, inspect(pledges))
  end
end
