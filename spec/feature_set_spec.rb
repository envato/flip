require "spec_helper"

describe Flip::FeatureSet do
  class NullStrategy < Flip::AbstractStrategy
    def knows?(d, options = {}); false; end
  end

  class TrueStrategy < Flip::AbstractStrategy
    def knows?(d, options = {}); true; end
    def on?(d, options = {}); true; end
  end

  class FalseStrategy < Flip::AbstractStrategy
    def knows?(d, options = {}); true; end
    def on?(d, options = {}); false; end
  end

  describe ".instance" do
    it "returns a singleton instance" do
      Flip::FeatureSet.instance.should equal(Flip::FeatureSet.instance)
    end

    it "can be reset" do
      instance_before_reset = Flip::FeatureSet.instance
      Flip::FeatureSet.reset
      Flip::FeatureSet.instance.should_not equal(instance_before_reset)
    end

    it "can be reset multiple times without error" do
      2.times { Flip::FeatureSet.reset }
    end
  end

  describe "#has?" do
    subject(:feature_set) { Flip::FeatureSet.new }

    it "doesn't have the feature" do
      feature_set.has?(:super_sweet_feature).should be_false
    end

    context "with a feature with key super_sweet_feature" do
      before { feature_set << double(:key => :super_sweet_feature) }

      it "has the feature" do
        feature_set.has?(:super_sweet_feature).should be_true
      end
    end
  end

  describe "#on?" do
    let(:definition) { Flip::Definition.new(:feature) }
    subject(:feature_set) { Flip::FeatureSet.new }
    before { feature_set << definition }

    context "with always-false strategy" do
      before { feature_set.add_strategy FalseStrategy }

      it "returns the strategy result false" do
        expect(feature_set.on?(:feature)).to be_false
      end

      context "with feature set default true" do
        before { feature_set.default = true }

        it "returns the strategy result false" do
          expect(feature_set.on?(:feature)).to be_false
        end
      end

      context "with definition default true" do
        before { feature_set << Flip::Definition.new(:feature, :default => true) }

        it "returns the strategy result false" do
          expect(feature_set.on?(:feature)).to be_false
        end
      end
    end

    context "with always-true strategy" do
      before { feature_set.add_strategy TrueStrategy }

      context "and no defaults" do
        before { feature_set << Flip::Definition.new(:feature) }

        it "returns the strategy result true" do
          expect(feature_set.on?(:feature)).to be_true
        end
      end

      context "with feature set default false" do
        before { feature_set << Flip::Definition.new(:feature) }
        before { feature_set.default = false }

        it "returns the strategy result true" do
          expect(feature_set.on?(:feature)).to be_true
        end
      end

      context "with definition default false" do
        before { feature_set << Flip::Definition.new(:feature, :default => false) }

        it "returns the strategy result true" do
          expect(feature_set.on?(:feature)).to be_true
        end
      end
    end

    context "with null strategy" do
      before { feature_set.add_strategy NullStrategy }

      context "and feature set default" do
        let(:feature_set_default) { double }
        before { feature_set.default = feature_set_default }

        it "returns the feature set default" do
          expect(feature_set.on?(:feature)).to be(feature_set_default)
        end

        context "when default is a proc" do
          let(:proc_result) { double }
          let(:feature_set_default) { proc { proc_result } }

          it "returns the proc result" do
            expect(feature_set.on?(:feature)).to be(proc_result)
          end

          context "with an arity of 1" do
            let(:definition) { Flip::Definition.new(:feature, :on => true) }
            let(:feature_set_default) { proc { |definition| definition.options[:on] } }

            it "passes the definition to the proc" do
              expect(feature_set.on?(:feature)).to be_true
            end
          end

          context "with an arity of 2" do
            let(:feature_set_default) { proc { |_, options| options[:on] } }

            it "passes the options to the proc" do
              expect(feature_set.on?(:feature, :on => true)).to be_true
            end
          end
        end

        context "and definition default" do
          let(:definition_default) { double }
          let(:definition) { Flip::Definition.new(:feature, :default => definition_default) }

          it "returns the definition default" do
            expect(feature_set.on?(:feature)).to be(definition_default)
          end

          context "when default is a proc" do
            let(:proc_result) { double }
            let(:definition_default) { proc { proc_result } }

            it "returns the proc result" do
              expect(feature_set.on?(:feature)).to be(proc_result)
            end

            context "with an arity of 1" do
              let(:definition) { Flip::Definition.new(:feature, :default => definition_default, :on => true) }
              let(:definition_default) { proc { |definition| definition.options[:on] } }

              it "passes the definition to the proc" do
                expect(feature_set.on?(:feature)).to be_true
              end
            end

            context "with an arity of 2" do
              let(:definition_default) { proc { |_, options| options[:on] } }

              it "passes the options to the proc" do
                expect(feature_set.on?(:feature, :on => true)).to be_true
              end
            end
          end
        end
      end
    end
  end
end
