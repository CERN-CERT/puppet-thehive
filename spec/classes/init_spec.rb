require 'spec_helper'

describe 'thehive' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('thehive::install') }
      it { is_expected.to contain_class('thehive::config') }
      it { is_expected.to contain_class('thehive::service') }
    end
  end
end
