#!/usr/bin/env ruby

require "xcodeproj"

bundle_id = ENV["IOS_BUNDLE_ID"]&.strip
abort "Set IOS_BUNDLE_ID, for example com.yourname.shoppingguardian" if bundle_id.nil? || bundle_id.empty?
unless bundle_id.match?(/\A[A-Za-z0-9]+(?:[.-][A-Za-z0-9]+)+\z/)
  abort "IOS_BUNDLE_ID is not a valid reverse-DNS identifier"
end

app_group = ENV.fetch("IOS_APP_GROUP", "group.#{bundle_id}").strip
unless app_group.match?(/\Agroup\.[A-Za-z0-9]+(?:[.-][A-Za-z0-9]+)+\z/)
  abort "IOS_APP_GROUP must start with group. and use a reverse-DNS identifier"
end

root = File.expand_path("..", __dir__)
project_path = File.join(root, "ios/Runner.xcodeproj")
project = Xcodeproj::Project.open(project_path)

identifiers = {
  "Runner" => bundle_id,
  "RunnerTests" => "#{bundle_id}.RunnerTests",
  "ShareExtension" => "#{bundle_id}.ShareExtension",
}
identifiers.each do |target_name, identifier|
  target = project.targets.find { |candidate| candidate.name == target_name }
  abort "#{target_name} target not found" unless target
  target.build_configurations.each do |configuration|
    configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = identifier
  end
end
project.save

entitlements = [
  File.join(root, "ios/Runner/Runner.entitlements"),
  File.join(root, "ios/ShareExtension/ShareExtension.entitlements"),
]
entitlements.each do |path|
  content = File.read(path)
  updated = content.sub(
    %r{<string>group\.[A-Za-z0-9.-]+</string>},
    "<string>#{app_group}</string>"
  )
  abort "App Group entry not found in #{path}" if updated == content
  File.write(path, updated)
end

store_path = File.join(root, "ios/Shared/SharedTextStore.swift")
store = File.read(store_path)
updated_store = store.sub(
  /static let appGroup = "group\.[A-Za-z0-9.-]+"/,
  "static let appGroup = \"#{app_group}\""
)
abort "App Group entry not found in SharedTextStore.swift" if updated_store == store
File.write(store_path, updated_store)

puts "Configured iOS bundle ID: #{bundle_id}"
puts "Configured iOS App Group: #{app_group}"
