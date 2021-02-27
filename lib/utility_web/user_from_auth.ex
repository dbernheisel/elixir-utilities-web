defmodule UtilityWeb.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger

  def find_or_create(%Ueberauth.Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp avatar_from_auth(%{info: %{urls: %{avatar_url: image}}}), do: image
  defp avatar_from_auth(auth), do: nil

  defp basic_info(auth) do
    %{
      id: "#{auth.provider}-#{auth.uid}",
      name: name_from_auth(auth),
      avatar: avatar_from_auth(auth),
      username: username_from_auth(auth)
    }
  end

  defp username_from_auth(%{info: %{nickname: username}}), do: username

  defp name_from_auth(%{info: %{name: name}}) when is_binary(name), do: name

  defp name_from_auth(%{info: %{first_name: first, last_name: last}})
       when is_binary(first) and is_binary(last) and first != "" and last != "" do
    Enum.join([first, last], " ")
  end
  defp name_from_auth(auth), do: username_from_auth(auth)

end
