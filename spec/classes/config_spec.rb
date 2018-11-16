require 'spec_helper'

describe 'thehive::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('thehive::install') }

      it do
        is_expected.to contain_file('/etc/thehive').with(
          'ensure' => 'directory',
          'owner' => 'thehive',
          'group' => 'thehive',
          'mode' => '0550'
        )
      end

      it do
        is_expected.to contain_file('/etc/thehive/application.conf').with(
          'ensure' => 'file',
          'owner' => 'thehive',
          'group' => 'thehive',
          'mode' => '0440'
        )
      end

      it do
        is_expected.to contain_file('/usr/share/elasticsearch', '/usr/share/elasticsearch/thehive').with(
          'ensure' => 'directory',
          'owner' => 'thehive',
          'group' => 'thehive',
          'mode' => '0660'
        )
      end

      it do
        is_expected.to contain_sysctl('vm.max_map_count').with(
          'val' => '262144'
        )
      end

      it { is_expected.to contain_docker__image('docker.elastic.co/elasticsearch/elasticsearch:5.6.14') }

      it do
        is_expected.to contain_docker__run('elasticsearch').with(
          'hostname' => 'elasticsearch',
          'image' => 'docker.elastic.co/elasticsearch/elasticsearch:5.6.14',
          'ports' => ['127.0.0.1:9200:9200', '127.0.0.1:9300:9300'],
          'volumes' => 'thehive:/usr/share/elasticsearch/thehive',
          'env' => ['http.host=0.0.0.0',
                    'transport.host=0.0.0.0',
                    'xpack.security.enabled=false',
                    'cluster.name=hive',
                    'thread_pool.search.queue_size=100000']
        )
      end
    end
  end
end
