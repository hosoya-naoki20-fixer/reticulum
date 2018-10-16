defmodule RetWeb.RetChannel do
  @moduledoc "Global comms channel for reticulum cluster"

  use RetWeb, :channel

  alias Ret.{Statix}
  alias RetWeb.{Presence}

  intercept(["presence_diff"])

  def join("ret", %{"hub_id" => hub_id}, socket) do
    Statix.increment("ret.channels.ret.joins.ok")
    send(self(), {:begin_tracking, socket.assigns.session_id, hub_id})
    {:ok, "{}", socket}
  end

  def handle_info({:begin_tracking, session_id, hub_id}, socket) do
    {:ok, _} = Presence.track(socket, session_id, %{hub_id: hub_id})
    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_out("presence_diff", _payload, socket) do
    # Do not send presence updates on this channel, for privacy reasons
    {:noreply, socket}
  end
end