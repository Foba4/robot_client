require "net/http"
require "uri"
require "json"
require "csv"

class Robot
  def initialize(argv)
    @out_format, @username, @userpwd = argv
    begin
      arg_number_verification(argv)
      authenticatification
      json_csv_verification
      response = http_connection("http://localhost/", 3000, "/programing_languages")
    rescue ArgumentError => e
      p e.message
    rescue Errno::ECONNREFUSED
      p "Please verify the server is running"
    else
      output(response)
    end
  end

  private

  def arg_number_verification(argv)
    if argv.length < 3 or argv.length > 3
      raise ArgumentError.new("number of argument exception, try: ruby robot_api_client.rb [OUTPUT_FORMAT(csv or json)] [BASIC_AUTH_ID] [BASIC_AUT_PASSWORD]")
    end
  end

  # authentification pass without credentials so we enforce the authenfication with hard coded user infos
  def authenticatification
    unless @username == "username" && @userpwd == "secretpassword"
      raise ArgumentError.new("Authentification failed!")
    end
  end

  def json_csv_verification
    unless @out_format == "json" or @out_format == "csv"
      raise ArgumentError.new("Only json and CSV are accepted as output format!")
    end
  end

  def http_connection(host, port, api_url)
    uri = URI.parse(host)
    http = Net::HTTP.new(uri.host, port)
    request = Net::HTTP::Get.new(api_url)
    request.basic_auth(@username, @userpwd)
    response = http.request(request)
  end

  def output(response)
    case @out_format
    when "json"
      #puts JSON.parse(response.body)
      puts response.body
    when "csv"
      csv_string = CSV.generate do |csv|
        JSON.parse(response.body).each do |hash|
          csv << hash.values
        end
      end

      puts csv_string
    end
  end
end

robot = Robot.new(ARGV)
