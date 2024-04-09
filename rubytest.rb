# Load Ruby files from local directory
this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, "lib")
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require "grpc"
require "json"
require "bag_services_pb"
require "dotenv/load"

PERMISSIONS = {
  ADMIN: 4,
  WRITE: 3,
  WRITE_SPECIFIC: 2,
  READ_PRIVATE: 1,
  READ: 0,
}

class Client
  attr_accessor :client
  attr_accessor :request

  def initialize(options)
    if !options.has_key?(:app_id) or !options.has_key?(:key)
      raise "Error: app_id and/or key not provided"
    end

    @request = { appId: options[:app_id], key: options[:key] }
    stub = Bag::BagService::Stub.new(options[:host] || "bag-7oiuqlq3ba-uk.a.run.app", :this_channel_is_insecure)
    begin
      verify = stub.verify_key(Bag::VerifyKeyRequest.new(@request))
      if !verify.valid
        raise "Error: app_id and/or key invalid"
      end
      @client = stub
    rescue GRPC::BadStatus => e
      abort "Error: #{e.message}"
    end
  end

  def format(obj)
    obj = obj.to_h 
    if obj[:response].length != 0
      raise obj[:response]
    end
    obj.each do |entry, value|
      if entry == "metadata"
        obj[entry] = JSON.parse(value)
        if obj[entry].class == String
          obj[entry] = JSON.parse(obj[entry])
        end
      elsif value == Object
        obj[entry] = format(value)
      end
    end
  end

  def read_item(request)
    begin
      resp = @client.read_items(Bag::ReadItemRequest(@request.merge(request)))
      return format(resp)
    rescue GRPC::BadStatus => e
      abort "Error: #{e.message}"
    end
  end

  def read_items(request)
    begin
      resp = @client.read_items(Bag::ReadItemsRequest.new(@request.merge(request)))
      return format(resp)
    rescue GRPC::BadStatus => e
      abort "Error: #{e.message}"
    end
  end
end

client = Client.new({ app_id: ENV['APP_ID'].to_i, key: ENV['APP_KEY']})
hat = client.read_items({ query: { name: "Hat" }.to_json })[:items][0]
p hat[:description]