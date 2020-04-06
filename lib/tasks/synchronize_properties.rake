namespace :synchronize_properties do
  desc 'Downloads and synchronizes properties from external portals'
  task all: :environment do
    EasyBrokerSynchronizer.synchronize
  end
end
