task default: ['build:run']

namespace 'test' do
  desc 'Run the test suite' 
  task :run do |t|
    puts "Running test suite"
    Rake::Task['build:run'].invoke
    code = system('mocha --compilers coffee:coffee-script --recursive')
    exit(code)
  end

  desc 'Run the test suite and watch for changes'
  task :watch do |t|
    puts "Watching for changes in src/, test/, and dist/"
    system 'mocha --compilers coffee:coffee-script -w --recursive'
  end
end

namespace 'build' do
  desc 'Clean the current build area'
  task :clean do |t|
    puts "Cleaning current build from dist/"
    system 'bundle exec rakep clean'
  end

  desc 'Execute a build'
  task :run do |t|
    Rake::Task['build:clean'].invoke
    puts "Building into dist/"
    system 'bundle exec rakep build'
  end

  desc 'Watch for changes then perform a build'
  task :watch do |t|
    puts "Watching for changes in src/"
    system 'bundle exec guard start --no-interactions'
  end
end