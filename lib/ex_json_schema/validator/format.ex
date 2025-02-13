defmodule ExJsonSchema.Validator.Format do
  alias ExJsonSchema.Validator
  alias ExJsonSchema.Validator.Error

  @formats %{
    "date-time" =>
      ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])[tT](2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?([zZ]|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])?$/,
    "email" =>
      ~r<^[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{|}~^-]+)*@(?:[A-Z0-9-]+\.)+[A-Z]{2,6}$>i,
    "hostname" => ~r/^((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}$/i,
    "ipv4" =>
      ~r/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/,
    "ipv6" =>
      ~r/^(?:(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}|(?=(?:[A-F0-9]{0,4}:){0,7}[A-F0-9]{0,4}$)(([0-9A-F]{1,4}:){1,7}|:)((:[0-9A-F]{1,4}){1,7}|:)|(?:[A-F0-9]{1,4}:){7}:|:(:[A-F0-9]{1,4}){7})$/i
  }

  @spec validate(String.t(), ExJsonSchema.data()) :: Validator.errors()
  def validate(format, data) when is_binary(data) do
    do_validate(format, data)
  end

  def validate(_, _), do: []

  defp do_validate(format, data)
       when format in ["date-time", "email", "hostname", "ipv4", "ipv6"] do
    case Regex.match?(@formats[format], data) do
      true -> []
      false -> [%Error{error: %Error.Format{expected: format}, path: ""}]
    end
  end

  defp do_validate(format, data) do
    case Application.fetch_env(:ex_json_schema, :custom_format_validator) do
      :error ->
        []

      {:ok, {mod, fun}} ->
        case apply(mod, fun, [format, data]) do
          true -> []
          false -> [%Error{error: %Error.Format{expected: format}, path: ""}]
        end
    end
  end
end
