# == Class: thehive
#
# Install, configure, and deploy TheHive.
class thehive (
  # Key for setting up cookies authentication for the Play Framework.
  # This can be generated with: `cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`
  String $play_secret_key,
  # The port where the TheHive server should be started.
  Integer $port = 9000,
  String $user = 'thehive',
  String $group = 'thehive',
  String $config_dir = '/etc/thehive',
  String $config_file = 'application.conf',
  # Increase the limit of mmap count, so ElasticSearch doesn't throw a memory exception during startup.
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
  Integer $vm_max_map_count = 262144,
  # ElasticSearch configuration variables.
  Boolean $elasticsearch_enabled = true,
  Integer $elasticsearch_uid = 1000,
  String $elasticsearch_index = 'the_hive',
  String $elasticsearch_cluster_name = 'hive',
  String $elasticsearch_host_address = '127.0.0.1',
  String $elasticsearch_transport_host_address = '0.0.0.0',
  Integer $elasticsearch_host_port = 9300,
  Integer $elasticsearch_thread_pool_search_queue_size = 100000,
  String $elasticsearch_docker_image = 'docker.elastic.co/elasticsearch/elasticsearch:5.6.14',
  String $elasticsearch_docker_volume_name = 'thehive',
  String $elasticsearch_docker_volume_path_parent = '/usr/share/elasticsearch',
  String $elasticsearch_docker_volume_path = '/usr/share/elasticsearch/thehive',
  String $elasticsearch_scroll_keepalive = '1m',
  Integer $elasticsearch_scroll_pagesize = 50,
  Integer $elasticsearch_shards_count = 5,
  Integer $elasticsearch_replicas_count = 1,
  Integer $elasticsearch_max_nested_fields = 100,
  Boolean $elasticsearch_xpack_enabled = false,
  String $elasticsearch_xpack_username = '',
  String $elasticsearch_xpack_password = '',
  Boolean $elasticsearch_ssl_enabled = false,
  String $elasticsearch_certificate_authority_path = '',
  String $elasticsearch_certificate_path = '',
  String $elasticsearch_ssl_key = '',
  Boolean $elasticsearch_searchguard_enabled = false,
  String $elasticsearch_searchguard_keystore_path = '',
  String $elasticsearch_searchguard_keystore_password = '',
  String $elasticsearch_searchguard_truststore_path = '',
  String $elasticsearch_searchguard_truststore_password = '',
  Boolean $elasticsearch_searchguard_host_verification = false,
  Boolean $elasticsearch_searchguard_host_verification_resolve_hostname = false,
  # Authorization configuration variables.
  Array $auth_providers = ['local'],
  Boolean $auth_basic_enabled = false,
  Boolean $auth_active_directory_enabled = false,
  # Configuration variables for setting up Active Directory authentication.
  String $auth_ad_domain_fqdn = '',
  String $auth_ad_server_names = '',
  String $auth_ad_domain_name = '',
  Boolean $auth_ad_use_ssl = true,
  # Configuration variables for setting up LDAP authentication.
  Boolean $auth_ldap_enabled = false,
  String $auth_ldap_server_names = '',
  String $auth_ldap_account_bind_dn = '',
  String $auth_ldap_account_bind_pw = '',
  String $auth_ldap_account_base_dn = '',
  String $auth_ldap_filter = '',
  Boolean $auth_ldap_use_ssl = true,
  # Configuration variables for setting up OAuth2 and Single sign-on (SSO).
  Boolean $auth_oauth2_sso_enabled = false,
  String $auth_oauth2_client_id = 'thehive',
  String $auth_oauth2_secret = '',
  String $auth_oauth2_client_redirect_uri = '',
  String $auth_oauth2_response_type = 'code',
  String $auth_oauth2_grant_type = 'authorization_code',
  String $auth_oauth2_auth_url = '',
  String $auth_oauth2_token_url = '',
  String $auth_oauth2_user_url = '',
  # Standard for constructing an OAuth2 scope:
  # https://tools.ietf.org/html/rfc6749#section-3.3
  String $auth_oauth2_scope = 'read:user',
  String $auth_sso_mapper = 'group',
  String $auth_sso_login = 'username',
  String $auth_sso_name = 'name',
  String $auth_sso_groups = 'groups',
  Boolean $auth_sso_autocreate = true,
  Array $auth_sso_default_roles = [],
  # If set to `false`, the user would have to manually login by pressing the "Sign in with SSO" button.
  Boolean $auth_sso_autologin = true,
  String $auth_sso_group_url = '',
  Array[Hash] $auth_sso_mappings =
  [{'auth_sso_mapping_key' => 'cert',
    'auth_sso_mapping_permissions' => ['admin']}
  ],
  # Configuration variables for controlling session timeout.
  String $session_authentication_warning = '5m',
  String $session_authentication_inactivity = '1h',
  String $http_parser_maxmemorybuffer = '1M',
  String $http_parser_maxdiskbuffer = '1G',
  # Configuration variables required for connecting TheHive to Cortex instance(s).
  Boolean $cortex_enabled = false,
  Array[Hash[String, String]] $cortex_instances =
  [{'cortex_server_id' => 'cortex',
    'cortex_server_url' => 'http://localhost:9001',
    'cortex_server_key' => ''},
  ],
  # Configuration variables required for connecting TheHive to MISP instance(s).
  Boolean $misp_enabled = false,
  String $misp_interval = '1h',
  Array[Hash] $misp_instances =
  [{'misp_server_id' => 'misp',
    'misp_server_url' => '',
    'misp_server_tags' => 'misp',
    'misp_api_key' => '',
    'misp_case_template' => '',
    'misp_max_attributes_count' => 1000,
    'misp_max_json_size' => '1 MiB',
    'misp_max_last_publish_date' => '7 days',
    'misp_exclusion_organisations' => [],
    'misp_exclusion_tags' => [],
    'misp_ws_enabled' => false,
    'misp_ws_truststore_path' => '',
    'misp_ws_proxy' => '',
    'misp_ws_port' => '',
    'misp_purpose' => 'ImportAndExport'}
  ],
  ) {
  contain '::thehive::install'

  contain '::thehive::config'

  contain '::thehive::service'
}
