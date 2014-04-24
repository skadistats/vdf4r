require 'spec_helper'
require 'vdf4r/store'

module VDF4R
  describe Store do
    it 'defaults to a nested store for unknown keys' do
      subject['foo'].should be_kind_of(Store)
    end

    it 'preserves original on second access of unknown key' do
      store = subject['foo']['bar']
      subject['foo']['bar']['ohai'] = 1
      subject['foo']['bar'].should === store
    end

    describe '#traverse' do
      let(:path) { ['foo', 'bar'] }

      it 'follows path recursively to arbitrary depths' do
        subject['foo']['bar'] = 'ohai'
        subject.traverse(path).should eq('ohai')
      end
    end
  end
end