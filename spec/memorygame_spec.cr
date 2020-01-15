require "./spec_helper"

describe Memorygame::Card do
  card = Memorygame::Card.new(5)
  equal_card = Memorygame::Card.new(5)
  different_card = Memorygame::Card.new(1)

  it "flips when clicked" do
    card.click
    card.visible?.should eq(true)
    card.click
    card.visible?.should eq(true)
  end

  it "compares correctly to other cards" do
    (card == equal_card).should eq(true)
    (card == different_card).should eq(false)
  end
end

describe Memorygame::Field do
  field = Memorygame::Field.new
  it "generates 10 *pairs* of cards" do
    card_qty = field.cards.size
    card_pairs = field.cards.reduce({} of Int32 => Int32) do |memo, card|
      memo[card_value] = memo[card_value]? || 0
      memo[card_value] += 1
      memo
    end

    card_qty.should eq(20)
    card_pairs.size.should eq(10)
    card_pairs.each do |k, v|
      v.size.should eq(2)
    end
  end
end