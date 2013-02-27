namespace 'test' do

  task :run do |t|
    sh 'mocha --compilers coffee:coffee-script'
  end

  task :watch do |t|
    sh 'mocha --compilers coffee:coffee-script -w'
  end

end

task :build do |t|
  puts "Cleaning current build..."
  sh 'bundle exec rakep clean'
  puts "Building"
  sh 'bundle exec rakep build'
end