namespace :ctm do

  namespace :error do

    desc "Test email error handling"
    task :email => :environment do
      user = OpenStruct.new
      user.name = "Foo"
      user.email = "foobar.address@mbmortgage.com"
      message = Notifier.im_on_a_boat(user)
      Email::Postman.call message
    end

  end

end