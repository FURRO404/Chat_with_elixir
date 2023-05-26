#Chat.exs
defmodule Chat do
  def wipe_chatlogs do
    file_path = "chatlogs.txt"
    File.write(file_path, "")
    # Overwrite entire file to blank, will automatically create "chatlogs.txt"
  end

  def start() do
    message = IO.gets("Your message (Commands: exit, wipe): ") |> String.trim
    receiver_pid = spawn_link(&Chat.send_message/0)
    # magic

    case message do
      "exit" -> Process.exit(receiver_pid, :kill)
      "wipe" -> wipe_chatlogs()
      _ -> send(receiver_pid, {:SIGNAL, message})
      # commands, IS ORDER SPECIFIC
    end
    start()
    # recursively call this so our chat stays alive
  end

  def send_message do
    receive do
      # checks for the :SIGNAL atom with somne content
      {:SIGNAL, message} ->
        file_path = "chatlogs.txt"

        # opens file in append mode so it wont overwrite, shouldn't really be able to fail
        case File.open(file_path, [:append]) do
          {:ok, file} ->
            IO.write(file, "New message: " <> message <> "\n")
            File.close(file)
            {:ok, "Content successfully written to the file."}

          {:error, reason} ->
            {:error, "Failed to open the file: #{reason}"}
        end

      # if we get a random atom with some content, this will fire
      {content0, content1} ->
        IO.puts("Bad receive. Got atom :#{content0} with content #{content1}")
    end
  end
end

Chat.wipe_chatlogs()
Chat.start()
