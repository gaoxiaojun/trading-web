namespace :rails do
  namespace :freeze do
    desc "Lock to the current set of plugins, only works with plugins listed in svn:externals"
    task :plugins do
      $verbose = false
      `svn --version` rescue nil
      unless !$?.nil? && $?.success?
        $stderr.puts "ERROR: Must have subversion (svn) available in the PATH to lock this application's plugins"
        exit 1
      end

      `svn propget svn:externals vendor/plugins`.split(/\r?\n/).each do |plugin|
        directory, url = plugin.strip.split(/\s+/)
        revision = `svn info vendor/plugins/#{directory}`.sub(/^.*Revision:\s+(\d+).*$/m, '\1')

        rm_rf("vendor/plugins/#{directory}")
        system("svn export -r #{revision} '#{url}' vendor/plugins/#{directory}")

        File.open("vendor/plugins/#{directory}/REVISION_#{revision}", 'w') do |file|
          file << url
          file << "\n"
        end

        system("svn -q add vendor/plugins/#{directory}")
      end

      system("svn propset svn:externals '' vendor/plugins")
    end
  end
end
# vim:ft=ruby