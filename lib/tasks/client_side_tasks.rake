
namespace :coffee do
  desc "compile a single coffeescript file to javascript on stdout"
  task :compile, :filename do |t, args|
    filename = args.filename
    puts CoffeeScript.compile(File.open(filename))
  end
end
