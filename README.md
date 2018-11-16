### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)

## Overview

[TheHive](https://thehive-project.org) is a scalable, open source and free Security Incident Response Platform, tightly integrated with MISP (Open Source Threat Intelligence Platform), designed to make life easier for SOCs, CSIRTs, CERTs and any information security practitioner dealing with security incidents that need to be investigated and acted upon swiftly.

## Module description

This module is responsible for the installation, configuration, and deployment of TheHive application.

For storing data, TheHive uses ElasticSearch (version 5.x) for which a Docker container is created.

## Usage

### Configuring TheHive instance

The Puppet `thehive` class provides a default installation of TheHive. Before importing the `thehive` class, you should set up the secret key `play_secret_key`, which is used internally by the Play framework. Its value can either be specified using Heira (recommended), or using a class parameter.

> Note: This module does not handle a reverse proxy. An example for creating a reverse proxy using Apache is provided [below](#creating-a-reverse-proxy).

#### Using Heira

The default parameters are present in the [manifests/init.pp](manifests/init.pp) file, which one can override, if required. Since `play_secret_key` is a required parameter, its value must be specified. To change the port on which TheHive instance is listening, update the `port` variable in the Hiera configuration:

```yaml
thehive::play_secret_key: '<secret key>'
thehive::port: 9999
```

Then include `thehive` class in your manifest file.

```ruby
include ::thehive
```

#### Using a class declaration

The secret key and port can also be provided as a parameter to the class declaration.

```ruby
class thehive {
  play_secret_key => '<secret key>',
  port            => 9999
}
```

> Note: A random key of the required length can be generated with: `$ cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`

#### Creating a reverse proxy

To serve the web interface on a custom server, create a reverse proxy for Apache. A skeleton for setting up the reverse proxy is shown below:

```ruby
  # Setup reverse proxy.
  apache::vhost { $thehive_server_name:
    port              => $apache_https_port,
    servername        => $thehive_server_name,
      {
        'path'         => '/',
        'url'          => "http://127.0.0.1:${::thehive::port}/",
        'reverse_urls' => ["http://127.0.0.1:${::thehive::port}/"]
      },
    ],
  }

  apache::vhost { $thehive_server_name:
    port              => $apache_https_port,
    docroot           => $apache_document_root,
    serveradmin       => $thehive_server_admin,
    servername        => $thehive_server_name,
    ssl               => true,
    ssl_cert          => $tls_cert,
    ssl_key           => $tls_key,
    log_level         => 'info',
    access_log_format => 'combined',
    ssl_proxyengine   => true,
    proxy_pass        => [
      {
        'path'         => '/',
        'url'          => "http://127.0.0.1:${::thehive::port}/",
        'reverse_urls' => ["http://127.0.0.1:${::thehive::port}/"],
      },
    ],
    directories       => [
      {
        provider       => 'location',
        path           => '/',
        options        => '-Indexes',
        allow_override => 'None',
        auth_type      => 'None',
      },
    ],
    rewrites          => [
          {
            rewrite_rule => ['^/oauth/redirect$ /index.html [R,NE]']
          }
        ],
    require           => [Certmgr::Certificate['TLS certificate for TheHive and Cortex'], Selinux::Port['Apache access to TheHive']],
  }

```

For passing additional parameters, consult the documentation in: [https://forge.puppet.com/puppetlabs/apache](https://forge.puppet.com/puppetlabs/apache)

### TheHive configuration file

The template for TheHive configuration file is present in [templates/application.erb](templates/application.erb). The configurable parameters are listed below:

* `play_secret_key`: Play framework secret key
* `port`: The port on which TheHive instance should be listening (default: `9000`)
* `user`: User who owns the TheHive repository and configuration directory (default: `thehive`)
* `group`: Group who owns the TheHive repository and configuration directory (default: `thehive`)
* `config_dir`: The directory where TheHive should create its configuration file (default: `'/etc/thehive'`)
* `config_file`: Name of TheHive configuration file with its path (default: `'application.conf'`)
* `vm_max_map_count`: Used to Increase the limit of mmap count, so ElasticSearch doesn't throw a memory exception during startup (default: `262144`)
* `elasticsearch_enabled`: If true, configure the ElasticSearch Docker container (default: `true`)
* `elasticsearch_uid`: UID for elasticsearch user in Docker container (default: `1000`)
* `elasticsearch_index`: ElasticSearch index is similar to a database, which provides a type of data organisation mechanism (default: `'the_hive'`)
* `elasticsearch_cluster_name`: Elasticsearch cluster is a group of one or more Elasticsearch nodes instances that are connected together (default: `'hive'`)
* `elasticsearch_host_address`: Address where ElasticSearch is being hosted (default: `'127.0.0.1'`)
* `elasticsearch_host_port`: ElasticSearch host port (default: `9300`)
* `elasticsearch_transport_host_address`: ElasticSearch transport host is used for internal communication between nodes within the cluster (default: `'0.0.0.0'`)
* `elasticsearch_thread_pool_search_queue_size`: ElasticSearch thread pools are used to improve threads memory consumption. The queue size allow pending requests to be held instead of discarded (default: `100000`)
* `elasticsearch_docker_image`: Docker image used for ElasticSearch (default: `'docker.elastic.co/elasticsearch/elasticsearch:5.6.14'`)
* `elasticsearch_docker_volume_name`: Name of the Docker volume (default: `'thehive'`)
* `elasticsearch_docker_volume_path_parent`: Parent path for the Docker volume (default: `'/usr/share/elasticsearch'`)
* `elasticsearch_docker_volume_path`: Path where the Docker volume should be created (default: `'/usr/share/elasticsearch/thehive'`)
* `elasticsearch_scroll_keepalive`: How long Elasticsearch should keep the search context alive (default: `'1m'`)
* `elasticsearch_scroll_pagesize`: Indicates the number of results that should be returned (default: `50`)
* `elasticsearch_shards_count`: Elasticsearch index is made up of one or more shards. Each shard is a self-contained search engine that indexes and handles queries for a subset of the data in an Elasticsearch cluster (default: `5`)
* `elasticsearch_replicas_count`: If the node holding a primary shard dies, a replica is promoted to the role of primary (default: `1`)
* `elasticsearch_max_nested_fields`: Nested fields allow an array of objects to be indexed in a way that they can be queried independently of each other (default: `100`)
* `elasticsearch_xpack_enabled`: Specifiy whether Elastic Stack Features (formerly packaged as X-Pack) are enabled or not (default: `false`)
* `elasticsearch_xpack_username`: Username of XPack package
* `elasticsearch_xpack_password`: Password for XPack package
* `elasticsearch_ssl_enabled`: Enable SSL to connect to ElasticSearch (default: `false`)
* `elasticsearch_certificate_authority_path`: Path where the certificate authority file is present
* `elasticsearch_certificate_path`: Path where the certificate file is present
* `elasticsearch_ssl_key`: Path to SSL key file
* `elasticsearch_searchguard_enabled`: Search Guard can be used to secure the Elasticsearch cluster using different industry standard authentication techniques, like Kerberos, LDAP / Active Directory, JSON web tokens, TLS certificates, and Proxy authentication / SSO (default: `false`)
* `elasticsearch_searchguard_keystore_path`: Path to JKS file containing client certificate
* `elasticsearch_searchguard_keystore_password`: Password of the keystore
* `elasticsearch_searchguard_truststore_path`: Path to JKS file containing certificate authorities
* `elasticsearch_searchguard_truststore_password`: Password of the truststore
* `elasticsearch_searchguard_host_verification`: If `false`, Search Guard will not enforce hostname verification (default: `false`)
* `elasticsearch_searchguard_host_verification_resolve_hostname`: If hostname verification is enabled, specify if hostname should be resolved
* `auth_providers`: List of authentication providers. Available providers are services, `local`, `oauth2, sso`, `ad`, `ldap` (default: `['local']`)
* `auth_basic_enabled`: Specify if basic authentication is enabled or not (default: `false`)
* `auth_active_directory_enabled`: If `true`, use ActiveDirectory to authenticate users (default: `false`)
* `auth_ad_domain_fqdn`: The Windows domain name in DNS format. This parameter is required if the `auth_ad_server_names` is not used
* `auth_ad_server_names`: The Windows domain name(s) in DNS format
* `auth_ad_domain_name`: The Windows domain name using short format. If this parameter is not set, TheHive uses `domainFQDN`
* `auth_ad_use_ssl`: If `true`, use SSL to connect to the domain controller (default: `false`)
* `auth_ldap_enabled`: Specify if LDAP authentication is enabled or not (default: `false`)
* `auth_ldap_server_names`: The LDAP server name(s) or address(es). The port can be specified using the 'host:port' syntax
* `auth_ldap_account_bind_dn`: Account to use to bind to the LDAP server [required]
* `auth_ldap_account_bind_pw`: Password of the binding account [required]
* `auth_ldap_account_base_dn`: Base distinguished name (DN) to search users [required]
* `auth_ldap_filter`: Filter to search user in the directory server [required]
* `auth_ldap_use_ssl`: If `true`, use SSL to connect to the LDAP directory server (default: `false`)
* `auth_oauth2_sso_enabled`: Specify if OAuth2 and SSO are enabled or not (default: `false`)
* `auth_oauth2_client_id`: The OAuth2 client ID is a public identifier for apps (default: `'thehive'`)
* `auth_oauth2_secret`: The OAuth2 key is a secret known only to the application and the authorization server. It must be sufficiently random to not be guessable
* `auth_oauth2_client_redirect_uri`: After a user successfully authorizes an application, the authorization server will redirect the user back to the application with either an authorization code or access token in the URL
* `auth_oauth2_response_type`: OAuth2 response type can be `'code'` for requesting an authorization code, or `'token'` for requesting an access token (implicit grant) (default: `'code'`)
* `auth_oauth2_grant_type`: OAuth2 grant types include Authorization Code, Implicit, Password, Client Credentials, Device Code, and Refresh Token (default: `'authorization_code'`)
* `auth_oauth2_auth_url`: URL of the authorization server
* `auth_oauth2_token_url`: URL from where to get the access token
* `auth_oauth2_user_url`: User URL used for creating the request header
* `auth_oauth2_scope`: OAuth2 scope provides a way to limit the amount of access that is granted to an access token (default: `'read:user'`)
* `auth_sso_mapper`: Name of mapping class from user resource to backend user (default: `'group'`)
* `auth_sso_login`: SSO username for login (default: `'username'`)
* `auth_sso_name`: SSO name (default: `'name'`)
* `auth_sso_groups`: SSO groups (default: `'groups'`)
* `auth_sso_autocreate`: If `true`, the user will be auto created from SSO credentials (default: `true`)
* `auth_sso_default_roles`: List of default SSO roles, which can either be `'admin'`, `'limited_user'`, `'user'` or `'read_only_user'`
* `auth_sso_autologin`: If set to `false`, the user would have to manually login by pressing the "Sign in with SSO" button (default: `true`)
* `auth_sso_group_url`: SSO groups URL
* `auth_sso_mappings`: Mappings used for assigning permissions to groups. It contains an array of hashes with the following keys:
  - `auth_sso_mapping_key`: SSO mapping key (default: `['cert']`)
  - `auth_sso_mapping_permissions`: SSO mapping permissions (default: `['admin']`)
* `session_authentication_warning`: Maximum warning time between two requests without requesting authentication (default: `'5m'`)
* `session_authentication_inactivity`: Maximum inactivity time between two requests without requesting authentication (default: `'1h'`)
* `http_parser_maxmemorybuffer`: Maximum textual content length (default: `'1M'`)
* `http_parser_maxdiskbuffer`: Text based body parsers (such as text, json, xml or formUrlEncoded) use a max content length because they have to load all the content into memory (default: `'1G'`)
* `cortex_enabled`: Specify if Cortex integration is enabled or not (default: `false`)
* `cortex_instances`: List of Cortex instances to be integrated with TheHive. It contains an array of hashes with the following keys:
  - `cortex_server_id`: Cortex server ID (default: `'cortex'`)
  - `cortex_server_url`: Cortex server URL (default: `'http://localhost:9001'`)
  - `cortex_server_key`: Cortex server key
* `misp_enabled`: Specify if MISP integration is enabled or not (default: `false`)
* `misp_interval`: Interval between consecutive MISP event imports in hours [h] or minutes [m] (default: `'1h'`)
* `misp_instances`: List of MISP instances to be integrated with TheHive. It contains an array of hashes with the following keys:
  - `misp_server_id`: MISP server ID (default: `'misp'`)
  - `misp_api_key`: MISP API key
  - `misp_server_url`: MISP server URL
  - `misp_server_tags`: MISP server tags  (default: `'misp'`)
  - `misp_case_template`: Name of the case template in TheHive that shall be used to import MISP events as cases by default
  - `misp_max_attributes_count`: MISP events number of attributes (default: `1000`)
  - `misp_max_json_size`: The maximum size of JSON representation (default: `'1 MiB'`)
  - `misp_max_last_publish_date`: The age of the last publish date (default: `'7 days'`)
  - `misp_exclusion_organisations`: List of organisations that must be excluded from MISP
  - `misp_exclusion_tags`: List of tags that must be excluded from MISP
  - `misp_webserver_enabled`: Specify if MISP web server is enabled or not (default: `false`)
  - `misp_webserver_truststore_path`: Truststore path to use to validate the X.509 certificate of MISP
  - `misp_webserver_proxy`: MISP web server proxy to use
  - `misp_webserver_port`: MISP web server port to use
  - `misp_purpose`: MISP purpose defines if the instance can be used to import events (`ImportOnly`), export cases (`ExportOnly`) or both (`ImportAndExport`) (default: `'ImportAndExport'`)
