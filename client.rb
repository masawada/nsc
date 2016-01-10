require 'dotenv'
require 'aws-sdk'
require 'simple_color'

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

    @color = SimpleColor.new
  end

  def logger(color, message)
    if color
      @color.echos(color, message)
    else
      puts message
    end
  end

  def info(message)
    logger(nil, message)
  end

  def error(message)
    logger(:red, message)
  end

  def fetch(opts)
    source = opts.shift
    dst = opts.shift
    if source.empty?
      error('source not defined')
      return
    end

    if dst.empty?
      error('dst not defined')
      return
    end

    bucket_name, object_key = source.split('/', 2)
    File.open(dst, "w") do |file|
      @client.get_object(bucket: bucket_name, key: object_key) do |chunk|
        file.write(chunk)
      end
    end
  end

  def post(opts)
    source = opts.shift
    dst = opts.shift
    if source.empty?
      error('source not defined')
      return
    end

    if dst.empty?
      error('dst not defined')
      return
    end

    file = File.open(source)
    file_name = File.basename(source)

    @client.put_object(
        bucket: dst,
        body: file,
        key: file_name
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

  def create_bucket(bucket_list)
    if bucket_list.nil? || bucket_list.empty?
      error('no bucket names defined')
      return
    end

    bucket_list.each do |bucket_name|
      @client.create_bucket(bucket: bucket_name)
    end
  end

  def remove_bucket(bucket_list)
    if bucket_list.nil? || bucket_list.empty?
      error('no bucket names defined')
      return
    end

    bucket_list.each do |bucket_name|
      @client.delete_bucket(bucket: bucket_name)
    end
  end
end

# main
client = Client.new(AWS_ACCESS_KEY, AWS_SECRET_KEY, AWS_ENDPOINT)
case params
when Command.fetch?
  client.fetch(ARGV)
when Command.post?
  client.post(ARGV)
when Command.list?
  client.list(ARGV)
when Command.create_bucket?
  client.create_bucket(ARGV)
when Command.remove_bucket?
  client.remove_bucket(ARGV)
else
  puts "no commands detected"
end
