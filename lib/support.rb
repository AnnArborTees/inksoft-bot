require 'mysql2'

def initialize_config
  @config = YAML.load_file('config/config.yml').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  @mysql_options = @config[:mysql].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  @inksoft_credentials = @config[:inksoft].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end

def initialize_client
  Mysql2::Client.new(@mysql_options)
end

initialize_config
@client = initialize_client

