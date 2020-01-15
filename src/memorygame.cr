require "crsfml"

module Memorygame
  VERSION = "0.1.0"

  class Game
    SCREEN_WIDTH = 800
    SCREEN_HEIGHT = 600

    @window : SF::RenderWindow
    @field : Field

    def initialize
      window = SF::RenderWindow.new(SF::VideoMode.new(SCREEN_WIDTH, SCREEN_HEIGHT), "Memory Game", SF::Style::Default)
      window.vertical_sync_enabled = true
      @window = window
      @field = Field.new
    end

    def process_events
      while event = @window.poll_event
        if event.is_a?(SF::Event::Closed)
          @window.close
        end
        if event.is_a?(SF::Event::MouseButtonPressed)
          @field.process_click(event)
        end
      end
    end

    def update
      @field.update
    end

    def render
      @window.clear(SF::Color::Black)
      @window.draw(@field)
      @window.display
    end

    def run
      while @window.open?
        update
        process_events
        render
      end
    end
  end

  class Card
    include SF::Drawable

    CARD_TYPE_QTY = 9
    CARD_HEIGHT = 150
    CARD_WIDTH = 100
    TEXTURE = SF::Texture.from_file("resources/sprites/card_texture.png")

    @visible : Bool
    @card_value : Int32
    @sprite : SF::Sprite

    def initialize(card_value : Int32)
      @card_value = card_value % CARD_TYPE_QTY
      sprite = SF::Sprite.new
      sprite.texture = TEXTURE
      sprite.texture_rect = SF.int_rect(9 * 101, 0, 100, 150)
      sprite.position = {0,0}
      @sprite = sprite
      @visible = false
    end

    getter :card_value
    getter :sprite

    def visible?
      @visible
    end

    def ==(card : Card)
      @card_value == card.card_value
    end

    def flip
      if visible?
        turn_face_down
      else
        turn_face_up
      end
    end

    def turn_face_up
      @visible = true
      sprite.texture_rect = SF.int_rect(@card_value * 101, 0, 100, 150)
    end

    def turn_face_down
      @visible = false
      sprite.texture_rect = SF.int_rect(9 * 101, 0, 100, 150)
    end

    def clicked?(pos : Tuple(Int32, Int32))
      @sprite.global_bounds.contains?(pos)
    end

    def move(position : Tuple(Int32, Int32))
      @sprite.position = position
    end

    def draw(target, states)
      target.draw(@sprite)
    end
  end

  class Field
    include SF::Drawable

    TEXTURE = SF::Texture.from_file("resources/sprites/field_background.png")

    @background = SF::Sprite.new
    @cards : Array(Card)
    @selected_cards : Array(Card)

    def initialize
      background = SF::Sprite.new
      background.texture = TEXTURE
      background.position = {0,0}
      background.scale({1.3, 1.3})
      @background = background
      @cards = [] of Card
      Card::CARD_TYPE_QTY.times do |i|
        @cards.push(Card.new(i))
        @cards.push(Card.new(i))
      end
      @cards.shuffle!
      @selected_cards = [] of Card
      place_cards
    end

    def place_cards
      sep_x = (200 / 12.0).round.to_i
      sep_y = (150 / 6.0).round.to_i
      @cards.each_with_index do |card, ind|
        x = ind % 6
        y = ind // 6
        pos_x = (sep_x + Card::CARD_WIDTH * x + 2 * x * sep_x)
        pos_y = (sep_y + Card::CARD_HEIGHT * y + 2 * y * sep_y)
        card.move({pos_x, pos_y})
      end
    end

    def draw(target, states)
      target.draw(@background)
      @cards.each do |card|
        target.draw(card)
      end
    end

    def process_click(event : SF::Event::MouseButtonPressed)
      pos = {event.x, event.y}
      @cards.each do |card|
        if card.clicked?(pos) && !card.visible?
          card.flip
          @selected_cards.push(card)
        end
      end
    end

    def update
      check_match
    end

    private def check_match
      if @selected_cards.size == 2
        if !face_up_cards_match?
          sleep(1)
          @selected_cards.each &.flip
        end
        @selected_cards.clear
      end
    end

    private def face_up_cards_match?
      card_a, card_b = @selected_cards
      card_a == card_b
    end
  end
end
