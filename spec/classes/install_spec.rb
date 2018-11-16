require 'spec_helper'

describe 'thehive::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it do
        is_expected.to contain_package('thehive').with(
          'ensure' => 'present'
        )
      end
    end
  end
end
