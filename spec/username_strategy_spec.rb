require 'spec_helper'

describe Flip::UsernameStrategy do

  let(:definition) { double('definition').tap{ |d| d.stub(:key) { :one } } }
  let(:usernames) { 'megatron,optimus' }

  subject(:strategy) { Flip::UsernameStrategy.new }

  its(:switchable?) { should be_false }
  its(:description) { should be_present }

  before do
    strategy.stub(:get => usernames)
  end

  describe '#knows?' do
    it 'does not know features without a username' do
      strategy.knows?(definition).should be_false
    end

    it 'does not know features for a non-listed user' do
      strategy.stub(:get) { nil }
      strategy.knows?(definition, {:username => 'soundwave'}).should be_false
    end
    
    it 'does know features for a listed user' do
      strategy.knows?(definition, {:username => 'megatron'}).should be_true
    end
  end

  describe '#on?' do
    it 'is true for a user who has been specified' do
      strategy.on?(definition, {:username => 'megatron'}).should be_true
    end

    it 'is false for a user who has not been specified' do
      strategy.on?(definition, {:username => 'soundwave'}).should be_false
    end

    it 'is false when no user is supplied' do
      strategy.on?(definition).should be_false
    end
  end

end