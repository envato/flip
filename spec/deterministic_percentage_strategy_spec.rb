require 'spec_helper'

describe Flip::DeterministicPercentageStrategy do

  let(:definition) { double('definition').tap{ |d| d.stub(:key) { :one } } }
  let(:strategy) { Flip::DeterministicPercentageStrategy.new(data_store) }
  let(:data_store) { stub(:get => percentage) }
  let(:percentage) { 10 }

  subject { strategy }

  its(:switchable?) { should be_false }
  its(:description) { should be_present }

  describe '#knows?' do
    it 'does not know features that cannot be found' do
      data_store.stub(:get) { nil }
      strategy.knows?(definition).should be_false
    end
    
    it 'knows features that can be found' do
      data_store.stub(:get) { percentage }
      strategy.knows?(definition).should be_true
    end
  end

  describe '#on?' do
    it 'is true for a user within the percentage' do
      strategy.on?(definition, {:id => 1}).should be_true
    end

    it 'is false for a user who is not within the percentage' do
      strategy.on?(definition, {:id => 20}).should be_false
    end

    it 'is false when no user is supplied' do
      strategy.on?(definition).should be_false
    end
  end

end