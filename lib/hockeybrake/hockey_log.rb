#
# This class converts the given Airbrake XML data to the log format of the HockeyApp server
#
module HockeyBrake
  class HockeyLog

    #
    # Generates a string which can be sent to the hockey service
    #
    def self.generate(data)
      # the output
      output = ""

      # generate our time string
      dtstr = Time.now.strftime("%a %b %d %H:%M:%S %Z %Y")

      # write the header so that we have something to send
      output += "Package: #{HockeyBrake.configuration.app_bundle_id}\n"
      output += "Version: #{HockeyBrake.configuration.app_version}\n"
      output += "Date: #{dtstr}\n"

      # add the optional values if possible
      begin
        output += "Android: #{RUBY_PLATFORM}\n"
        output += "Model: Ruby #{RUBY_VERSION} Rails #{Rails.version}\n"
      rescue
        # nothing to do
      end

      # add the empty line
      output += "\n"

      # parse the XML and convert them to the HockeyApp format
      begin
        # xml parser
        crashData = Hash.from_xml(data)

        # write the first line
        output += "#{crashData['notice']['error']['class']}: #{crashData['notice']['error']['message']}\n"

        # parse the lines
        lines = crashData['notice']['error']['backtrace']['line']
        lines.each do |line|
          class_name =   File.basename(line['file'], ".rb").classify
          output += "    at #{class_name}##{line['method']}(#{line['file']}:#{line['number']})\n"
        end
      rescue
        # nothing to do
      end

      # return the output
      output
    end
  end
end