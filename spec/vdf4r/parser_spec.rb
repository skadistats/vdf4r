require 'spec_helper'

require 'vdf4r'
require 'stringio'

module VDF4R
  describe Parser do
    subject { VDF4R::Parser }

    describe 'class methods' do
      context 'input safety' do
        let(:dirty) { '"foo\"\"bar\""' }
        let(:clean) { '"foo&quot;&quot;bar&quot;"' }

        describe '#clean' do
          it 'replaces escaped quotes with token' do
            expect(subject.clean(dirty)).to eq(clean)
          end
        end

        describe '#dirty' do
          it 'replaces tokens with escaped quote' do
            expect(subject.dirty(clean)).to eq(dirty)
          end
        end
      end
    end

    describe 'instantiation' do
      shared_examples_for "doesn't raise" do
        it 'does not raise' do
          expect {
            subject.new(input)
          }.not_to raise_error
        end
      end

      context 'with string' do
        let(:input) { 'foo\nbar\n'}
        it_behaves_like "doesn't raise"
      end

      context 'with io' do
        let(:input) { StringIO.new('input') }
        it_behaves_like "doesn't raise"
      end

      context 'quacks right' do
        let(:input) do
          quacker = Class.new do
            def lines
              ['line 1', 'line 2']
            end
          end
          quacker.new
        end

        it_behaves_like "doesn't raise"        
      end

      context 'with inappropriate input' do
        let(:input) { 1234 }

        it 'raises' do
          expect {
            subject.new(input)
          }.to raise_error
        end
      end
    end

    describe 'usage example (items.txt)' do
      let(:result) do
        with_fixture('items') do |fixture|
          subject.new(fixture).parse
        end
      end

      it 'quacks like hash' do
        expect(result).to respond_to(:keys)
      end

      it 'has the correct root' do
        expect(result.keys.length).to eq(1)
        expect(result.keys).to include('DOTAAbilities')
      end

      it 'has a sampling of correct top-level child entries' do
        abilities = result['DOTAAbilities']
        expect(abilities).to include('item_blink')
        expect(abilities).to include('item_blades_of_attack')
        expect(abilities).to include('item_broadsword')
        expect(abilities).to include('item_black_king_bar')
      end
    end

    describe 'usage example (dota_english.txt)' do
      let(:result) do
        with_fixture('dota_english') do |fixture|
          subject.new(fixture).parse
        end
      end

      it "doesn't raise" do
        expect {
          result
        }.not_to raise_error
      end

      it 'parses multi-line values' do
        tokens = result['lang']['Tokens']
        expect(tokens).to include('DOTA_Archronicus_MadMoon_Page4')
        expect(tokens).to include('npc_dota_hero_rattletrap_bio')

        page_num_lines = tokens['DOTA_Archronicus_MadMoon_Page4'].count("\n") + 1
        expect(page_num_lines).to eq(3)

        bio_num_lines = tokens['npc_dota_hero_rattletrap_bio'].count("\n") + 1
        expect(bio_num_lines).to eq(3)
      end
    end

    describe 'bad input' do
      def parse_fixture(fixture_name)
        with_fixture(fixture_name) do |fixture|
          subject.new(fixture).parse
        end
      end

      it 'raises on unbalanced nesting (insufficient exit)' do
        expect { parse_fixture('bad/insufficient_exit') }.to raise_error /insufficient exit/
      end

      it 'raises on unbalanced nesting (excessive exit)' do
        expect { parse_fixture('bad/excessive_exit') }.to raise_error /excessive exit/
      end
 
      it 'raises on ungrammatical content' do
        expect { parse_fixture('bad/ungrammatical_content') }.to raise_error /ungrammatical content/
      end

      it 'raises when too recursive' do
        expect { parse_fixture('bad/too_recursive') }.to raise_error /too recursive/
      end

      it 'raises on no preceding key' do
        expect { parse_fixture('bad/no_preceding_key') }.to raise_error /no preceding key/
      end

      describe 'multi-line values' do
        it 'raises on enter' do
          expect { parse_fixture('bad/multi_line_enter') }.to raise_error /enter/
        end

        it 'raises on exit' do
          expect { parse_fixture('bad/multi_line_exit') }.to raise_error /exit/
        end
      end
    end
  end
end