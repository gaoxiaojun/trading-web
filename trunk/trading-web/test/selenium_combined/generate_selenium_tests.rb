path = File.dirname(__FILE__)
output_file_name = path +'/selenium.html'
File.delete output_file_name if File.exists? output_file_name
selenium_tests_path = path.gsub(/selenium_combined/,'selenium')
entries = Dir.entries(selenium_tests_path)
File.open(output_file_name, 'w') do |sel_file|
  entries.each do |file_name|
     next unless file_name.match(/rhtml/)
    file = IO.read(File.join(selenium_tests_path, file_name))
    sel_file.puts file.to_s
  end
end