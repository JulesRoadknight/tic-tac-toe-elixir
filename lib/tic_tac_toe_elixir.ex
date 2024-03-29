defmodule TicTacToeElixir do
  def start(in_out\\ ConsoleInOut) do
    Logger.configure(level: :notice)

    Database.connect() |> in_out.print
    game_history = Database.get_all_records()
    "Number of games in history: #{length(game_history)}" |> in_out.print

    greet() |> in_out.print
    explain_rules() |> in_out.print

    menu(in_out)
  end

  defp greet, do: "\n===Welcome to TicTacToe - Elixir Edition!===\n"

  defp explain_rules, do: "\nThe first player to move is X. To make a move, type the number of an unmarked square.\nTo win, be the first to place three of your markers in a row horizontally, vertically, or diagonally.\n"

  defp menu(in_out) do
    case "\nEnter a number to choose:\n1. Play a game\n2. View game history\n3. Quit\n" |> in_out.read_input do
      "1" -> set_up_game(in_out)
      "2" -> game_history_menu(in_out)
      _default -> true
    end
  end

  defp set_up_game(in_out) do
    player_one = %Player{
      name: get_player_name(in_out, true, "1", "X"),
      marker: get_player_marker(in_out, "X", true)
    }
    human_player_two? = is_player_two_human?(in_out)
    player_two = %Player{
      human?: human_player_two?,
      name: get_player_name(in_out, human_player_two?, "2", "CPU"),
      marker: get_player_marker(in_out, "O", human_player_two?, player_one.marker)
    }
    Game.game_loop(false, "123456789", player_one, player_two, player_one.marker, 1, in_out) |> Board.winner(player_one, player_two) |> in_out.print
    menu(in_out)
  end

  defp get_player_marker(in_out, default_marker, human?, player_one_marker\\"?") do
    if human? do
      get_marker_loop(in_out, default_marker, human?, player_one_marker, ~r/^[A-z]{1}$/)
    else
      default_marker
    end
  end

  defp get_marker_loop(in_out, default_marker, human?, player_one_marker, validation) do
    marker = "\nPlease enter your marker (1 letter): \n" |> in_out.read_input
    cond do
      String.match?(marker, validation) and marker != player_one_marker -> marker
      true -> get_marker_loop(in_out, default_marker, human?, player_one_marker, validation)
    end
  end

  defp is_player_two_human?(in_out), do: "\nIs player two human? (y/N)\n" |> in_out.read_input |> String.match?(~r/y/i)

  defp get_player_name(in_out, human?, which_player, default) do
    if human? do
      get_name_loop(in_out, human?, which_player, default, ~r/^[A-z]{1,3}$/)
    else
      default
    end
  end

  defp get_name_loop(in_out, human?, which_player, default, validation) do
    name = "\nPlease enter player #{which_player} name (up to 3 letters):\n" |> in_out.read_input
    cond do
      String.match?(name, validation) -> name
      true -> get_name_loop(in_out, human?, which_player, default, validation)
    end
  end

  defp game_history_menu(in_out) do
    case "\nEnter a number to choose:\n1. View list of games\n2. View a game by ID\n3. Search games by player name\n4. Return to main menu\n5. Quit\n" |> in_out.read_input do
      "1" -> view_game_history(in_out)
      "2" -> view_specific_game(in_out)
      "3" -> search_games_by_player_name(in_out)
      "4" -> menu(in_out)
      _default -> true
    end
  end

  defp view_game_history(in_out) do
    format_game_loop(Database.get_all_records(), in_out)
    game_history_menu(in_out)
  end

  defp view_specific_game(in_out) do
    in_out.read_input("\n---Enter the ID of a game to view---\n") |> Database.get_record_by_id |> format_game_display(in_out)
    game_history_menu(in_out)
  end

  defp search_games_by_player_name(in_out) do
    in_out.read_input("\n---Enter the name of a player to search---\n") |> Database.get_records_by_player_name |> format_game_loop(in_out)
    game_history_menu(in_out)
  end

  def format_game_loop(records, in_out), do: Enum.map(records, fn(record) -> format_game_history(record, in_out) end)

  defp format_game_display(record, in_out) do
    "---Game #{record.id}---" |> in_out.print
    "P1 Name: #{record.player_one_name}" |> in_out.print
    "P2 Name: #{record.player_two_name}" |> in_out.print
    "Date: #{record.updated_at}" |> in_out.print
    "Final Board:\n#{Board.split_board(record.board_state)}\n" |> in_out.print
  end

  def format_game_history(record, in_out) do
    "\n---Game Record---" |> in_out.print
    "Game ID: #{record.id}" |> in_out.print
    "P1 Name: #{record.player_one_name}" |> in_out.print
    "P2 Name: #{record.player_two_name}" |> in_out.print
    "Date: #{record.updated_at}" |> in_out.print
  end
end
