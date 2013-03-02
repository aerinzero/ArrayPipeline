namespace 'test' do
  task :run do |t|
    sh 'mocha --compilers coffee:coffee-script --recursive'
  end

  task :watch do |t|
    sh 'mocha --compilers coffee:coffee-script -w --recursive'
  end
end

namespace 'build' do
  task :clean do |t|
    puts "Cleaning current build..."
    sh 'bundle exec rakep clean'
  end

  task :build do |t|
    puts "Building"
    sh 'bundle exec rakep build'
  end

  task :watch do |t|
    puts "Watching for changes in src/"
    sh 'bundle exec guard start --no-interactions'
  end
end