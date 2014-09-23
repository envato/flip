require 'spec_helper'

describe Flip::DeterministicPercentageStrategy do

  let(:definition) { double('definition').tap{ |d| d.stub(:key) { :one } } }
  let(:percentage) { 10 }

  subject(:strategy) { Flip::DeterministicPercentageStrategy.new }

  before do
    strategy.stub(:get => percentage)
  end

  its(:switchable?) { should be_false }
  its(:description) { should be_present }

  describe '#knows?' do
    it 'does not know features without a percentage' do
      strategy.knows?(definition).should be_false
    end

    it 'does not know features where the entity does not fall with the percentage range' do
      strategy.stub(:get) { 0 }
      strategy.knows?(definition, {:id => 1}).should be_false
    end
    
    it 'knows features where the entity does fall within the percentage range' do
      strategy.stub(:get) { 100 }
      strategy.knows?(definition, {:id => 1}).should be_true
    end
  end

  describe '#on?' do
    it 'is true for a user within the percentage' do
      strategy.stub(:get) { 100 }
      strategy.on?(definition, {:id => 1}).should be_true
    end

    it 'is false for a user who is not within the percentage' do
      strategy.stub(:get) { 0 }
      strategy.on?(definition, {:id => 20}).should be_false
    end

    it 'is false when no user is supplied' do
      strategy.on?(definition).should be_false
    end
  end

end