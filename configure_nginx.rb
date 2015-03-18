#!/usr/bin/env ruby

# Read the configuration file

lines = []
config = false

text=File.open('/opt/nginx/conf/nginx.conf').read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|

	if config
		if /\}/.match(line)
			config = false
		end
	else
		if /location \/ \{/.match(line)
			config = true

			lines << line
			lines << "            passenger_enabled on;"
			lines << "            rails_env production;"
			lines << "            root /srv/rails/app/public;"
		end
	end

	if !config
		lines << line
	end
end

# Write the configuration file

File.open('/opt/nginx/conf/nginx.conf', 'w') do |configFile|  
	lines.each do |line|
		configFile.puts line
	end
end
