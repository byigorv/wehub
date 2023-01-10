defmodule Hub do
  use Application

  def start(_type, _args) do
    Hub.App.start_link()
  end

end
