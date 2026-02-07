defmodule Pour.Uploads do
  def upload_to_s3(file_binary, filename) do
    bucket = Application.fetch_env!(:pour, :s3_bucket)
    key = "wines/#{filename}"

    case ExAws.S3.put_object(bucket, key, file_binary, content_type: content_type(filename))
         |> ExAws.request() do
      {:ok, _} ->
        url = build_url(bucket, key)
        {:ok, url}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete_from_s3(nil), do: :ok

  def delete_from_s3(url) do
    bucket = Application.fetch_env!(:pour, :s3_bucket)
    key = extract_key(url)

    case ExAws.S3.delete_object(bucket, key) |> ExAws.request() do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_url(bucket, key) do
    config = ExAws.Config.new(:s3)

    case config do
      %{host: host, scheme: scheme, port: port} when host != "" and not is_nil(host) ->
        "#{scheme}#{host}:#{port}/#{bucket}/#{key}"

      _ ->
        region = config[:region] || "us-east-1"
        "https://#{bucket}.s3.#{region}.amazonaws.com/#{key}"
    end
  end

  defp extract_key(url) do
    uri = URI.parse(url)
    # Handle both MinIO-style (/bucket/key) and AWS-style paths
    path = uri.path || ""

    path
    |> String.trim_leading("/")
    |> then(fn p ->
      bucket = Application.fetch_env!(:pour, :s3_bucket)

      if String.starts_with?(p, bucket <> "/") do
        String.trim_leading(p, bucket <> "/")
      else
        p
      end
    end)
  end

  defp content_type(filename) do
    case Path.extname(filename) |> String.downcase() do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".webp" -> "image/webp"
      _ -> "application/octet-stream"
    end
  end
end
