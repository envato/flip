require 'spec_helper'

describe Flip::UsernameStrategy do

  let(:definition) { double('definition').tap{ |d| d.stub(:key) { :one } } }
  let(:strategy) { Flip::UsernameStrategy.new(data_store) }
  let(:data_store) do
    stub('data_store',
      :get => usernames,
      :set => nil,
      :delete => nil,
    )
  end
  let(:usernames) { 'megatron,optimus' }

  subject { strategy }

  its(:switchable?) { should be_false }
  its(:description) { should be_present }

  describe '#knows?' do
    it 'does not know features that cannot be found' do
      data_store.stub(:get) { nil }
      strategy.knows?(definition).should be_false
    end
    
    it 'knows features that can be found' do
      data_store.stub(:get) { usernames }
      strategy.knows?(definition).should be_true
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