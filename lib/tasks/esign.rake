namespace :esign do

  namespace :update do

    desc "Update Esign Package Versions"
    task :package_versions => :environment do
      Esign::PopulatePackageVersions.call
    end

    desc "Update Esign Borrower Completions"
    task :borrower_completions => :environment do
      Esign::UpdateBorrowerCompletions.call
    end

    desc "Update Esign Package Versions and Borrower Completions"
    task :all => [:environment, :package_versions, :borrower_completions] do
    end
  
  end
end