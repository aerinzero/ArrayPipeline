# A sample Guardfile
# More info at https://github.com/guard/guard#readme

def rebuild
  system("/usr/bin/env", "bundle", "exec", "rakep", "build") 
end

group :app do 
  guard :shell do
    watch(%r{src/.+\.(coffee|js)$}) { |m| rebuild; n m[0], 'Changed' }
    watch(%r{Assetfile$}) { |m| rebuild; n m[0], 'Changed' }
  end
end