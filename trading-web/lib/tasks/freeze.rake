namespace :rails do
  namespace :freeze do
    desc "Lock to a specific rails version. Defaults to 1.1.5 or specify with RELEASE=x.y.z"
    task :version do
      rel = ENV['RELEASE'] || '1.1.5'
      tag = 'rel_' + rel.split(/[.-]/).join('-')
      rails_svn = "http://dev.rubyonrails.org/svn/rails/tags/#{tag}"

      puts "Freezing to #{tag} using #{rails_svn}"
      sh "type svn"
      
      dir = 'vendor/rails'
      rm_rf dir
      mkdir_p dir
      for framework in %w( railties actionpack activerecord actionmailer activesupport actionwebservice )
        checkout = "#{dir}/#{framework}"
        sh "svn export #{rails_svn}/#{framework} #{checkout}"
        unless test ?d, checkout then
          puts "ERROR: checkout missing: #{checkout}"
          exit 1
        end
      end
    end
  end
end

#rake rails:freeze:version
#default to 1.1.5 or you can specify the tagged version you want using RELEASE=x.y.z.