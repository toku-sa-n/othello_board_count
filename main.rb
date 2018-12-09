# Calcuate how many patterns there are in the board of othello game.
# The board is written as a form of this:
# 0000000000000000000000000001200000021000000000000000000000000000
# (The type of this number is STRING)
# This represents this:
# ........
# ........
# ........
# ...BW...
# ...WB...
# ........
# ........
# ........
# B:1 W:2 .:0
#
# "(0, 0)(0, 1)......(0, 7)(1, 0)......(7, 7)"

$possible_stone_arrange = []
$checking_board = nil
$width = 4
$height = 4

def AddHistory(text_format_board)
  if $possible_stone_arrange.include?(text_format_board) == false
    $possible_stone_arrange << text_format_board
  end
end

# Check whether you can place your stone.

def BoardFull?
  # Return true if the board is full of stone and false if not.
  $height.times do |i|
    return false if $checking_board[i].include?('0')
  end
  true
end

def StoneExist?(y, x)
  $checking_board[y][x] != '0'
end

def CoordInBoard?(y, x)
  return false if (y < 0) || (y > $height - 1)
  return false if (x < 0) || (x > $width - 1)

  true
end

def CanLocate?(y, x, turn)
  return false if StoneExist?(y, x)

  CanRotateStone?(y, x, turn)
end

def RotateTheDirection?(criteria_y, criteria_x, offset_y, offset_x, turn)
  y = criteria_y + offset_y
  x = criteria_x + offset_x
  return false if CoordInBoard?(y, x) == false
  return false if $checking_board[y][x] != ChangeTurn(turn) # Check whether the stone next to (y, x) is the same color.

  y += offset_y
  x += offset_x
  while CoordInBoard?(y, x)
    return true if $checking_board[y][x] == turn

    y += offset_y
    x += offset_x
  end
  false
end

def CanRotateStone?(criteria_y, criteria_x, turn)
  (-1..1).each do |offset_y|
    (-1..1).each do |offset_x|
      next if (offset_y == offset_x) && (offset_y == 0)

      return true if RotateTheDirection?(criteria_y, criteria_x, offset_y, offset_x, turn)
    end
  end
  false
end
# Reflect the actions.

def ChangeTurn(turn)
  return '2' if turn == '1'

  '1'
end

def RotateStones(criteria_y, criteria_x, turn)
  (-1..1).each do |offset_y|
    (-1..1).each do |offset_x|
      next if (offset_y == offset_x) && (offset_y == 0)

      next unless RotateTheDirection?(criteria_y, criteria_x, offset_y, offset_x, turn)

      y = criteria_y
      x = criteria_x
      while CoordInBoard?(y, x)
        break if $checking_board[y][x] == turn

        $checking_board[y][x] = turn
        y += offset_y
        x += offset_x
      end
    end
  end
end

def ToBoard(text_format_board)
  # Convert text_format_board to 2-dimention array
  $checking_board = Array.new($height).map { Array.new($width, 0) }
  $height.times do |y|
    $width.times do |x|
      $checking_board[y][x] = text_format_board[y * $height + x]
    end
  end
end

def ToTextForm
  text = Array.new($width * $height, 0)
  $height.times do |y|
    $width.times do |x|
      text[y * $height + x] = $checking_board[y][x]
    end
  end
  text
end

def CountPossibleArrange(text_format_board, turn)
  # Convert from text-formed to 2-dimention array
  # black_or_white:1:Black 2:White
  ToBoard(text_format_board)
  if BoardFull?() == false
    AddHistory(text_format_board)
    $height.times do |y|
      $width.times do |x|
        next unless CanLocate?(y, x, turn)

        RotateStones(y, x, turn)
        CountPossibleArrange(ToTextForm(), ChangeTurn(turn)) # ここで再帰を使用．
        ToBoard(text_format_board) # Back to previous board.
      end
    end
  end
end

CountPossibleArrange('0000012002100000', '1')
p $possible_stone_arrange.length
