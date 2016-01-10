require 'dotenv'
require 'aws-sdk'

Dotenv.load
AWS_ACCESS_KEY = ENV["AWS_ACCESS_KEY"]
AWS_SECRET_KEY = ENV["AWS_SECRET_KEY"]
AWS_ENDPOINT = ENV["AWS_ENDPOINT"]

# option parser
params = ARGV.getopts('', 'fetch', 'post', 'list', 'create_bucket', 'remove_bucket')

# command detector
module Command
  def self.detect_command(type)
    ->cmd{ cmd[type.to_s] === true }
  end

  def self.fetch?
    self.detect_command(:fetch)
  end

  def self.post?
    self.detect_command(:post)
  end

  def self.list?
    self.detect_command(:list)
  end

  def self.create_bucket?
    self.detect_command(:create_bucket)
  end

  def self.remove_bucket?
    self.detect_command(:remove_bucket)
  end
end

# list
class Client
  def initialize(key, pass, endpoint, region='us-east-1')
    credentials = Aws::Credentials.new(
      key,
      pass,
      nil
    )

    @client = Aws::S3::Client.new(
      credentials: credentials,
      endpoint: endpoint,
      region: region,
      force_path_style: true
    )
  end

  def list(bucket_list)
    # no bucket name
    if bucket_list.nil? || bucket_list.empty?
      res = @client.list_buckets
      res.buckets.each do |bucket|
        puts "#{bucket.name}, created at #{bucket.creation_date.localtime}"
      end
      return
    end

    bucket_list.each do |bucket_name|
      puts "#{bucket_name}:"
      resp = @client.list_objects(bucket: bucket_name)
      resp.contents.each do |content|
        puts "  #{content.key}"
      end
    end
  end
end

# main
client = Client.new(AWS_ACCESS_KEY, AWS_SECRET_KEY, AWS_ENDPOINT)
case params
when Command.fetch?
when Command.post?
when Command.list?
  client.list(ARGV)
else
  puts "no commands detected"
end
