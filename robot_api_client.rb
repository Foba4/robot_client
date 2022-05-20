require "net/http"
require "uri"
require "json"
require "csv"

class Robot
  attr_accessor :out_format, :username, :userpwd, :result

  def connect_and_display(argv = [])
    begin
      arg_number_verification(argv)
      out_format, username, userpwd = argv
      authenticatification(username, userpwd)
      json_csv_verification(out_format)
      response = http_get("http://localhost/", 3000, "/programing_languages",username, userpwd)
    rescue ArgumentError => e
      p e.message
    rescue Errno::ECONNREFUSED
      p "Please verify the server is running"
    else
      format_response(response)
    end
  end

  def arg_number_verification(argv)
    if argv.length < 3 or argv.length > 3
      raise ArgumentError.new("number of argument exception, try: ruby robot_api_client.rb [OUTPUT_FORMAT(csv or json)] [BASIC_AUTH_ID] [BASIC_AUT_PASSWORD]")
    end
  end

  # authentification pass without credentials so we enforce the authenfication with hard coded user infos
  def authenticatification(username, userpwd)
    @username = username
    @userpwd = userpwd
    unless @username == "username" && @userpwd == "secretpassword"
      raise ArgumentError.new("Authentification failed!")
    end
  end

  def json_csv_verification(out_format)
    @out_format = out_format
    unless @out_format == "json" or @out_format == "csv"
      raise ArgumentError.new("Only json and CSV are accepted as output format!")
    end
  end

  def http_get(host, port, api_url,username, userpwd)
    @username, @userpwd = username, userpwd
    uri = URI.parse(host)
    http = Net::HTTP.new(uri.host, port)
    request = Net::HTTP::Get.new(api_url)
    request.basic_auth(@username, @userpwd)
    response = http.request(request)
  end

  def format_response(response)
    case @out_format
    when "json"
      @result = JSON.parse(response.body)
      # @result = response.body
    when "csv"
      csv_string = CSV.generate do |csv|
        JSON.parse(response.body).each do |hash|
          csv << hash.values
        end
      end
      @result = csv_string
    end
  end
end

robot = Robot.new
robot.connect_and_display(ARGV)
puts robot.result

