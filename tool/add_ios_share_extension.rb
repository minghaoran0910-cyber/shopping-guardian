#!/usr/bin/env ruby

require "xcodeproj"

project_path = File.expand_path("../ios/Runner.xcodeproj", __dir__)
pubspec_path = File.expand_path("../pubspec.yaml", __dir__)
version = File.readlines(pubspec_path).find { |line| line.start_with?("version:") }
  &.split(":", 2)&.last&.strip
abort "Version not found in pubspec.yaml" unless version
marketing_version, build_number = version.split("+", 2)
abort "Invalid pubspec version: #{version}" unless marketing_version && build_number
project = Xcodeproj::Project.open(project_path)
runner = project.targets.find { |target| target.name == "Runner" }
abort "Runner target not found" unless runner

shared_group = project.main_group.find_subpath("Shared", true)
shared_group.set_source_tree("<group>")
shared_file = shared_group.files.find { |file| file.path == "Shared/SharedTextStore.swift" }
shared_file ||= shared_group.new_file("Shared/SharedTextStore.swift")
privacy_file = shared_group.files.find { |file| file.path == "Shared/PrivacyInfo.xcprivacy" }
privacy_file ||= shared_group.new_file("Shared/PrivacyInfo.xcprivacy")
unless runner.source_build_phase.files_references.include?(shared_file)
  runner.add_file_references([shared_file])
end
unless runner.resources_build_phase.files_references.include?(privacy_file)
  runner.resources_build_phase.add_file_reference(privacy_file)
end
runner_group = project.groups.find { |group| group.path == "Runner" }
abort "Runner group not found" unless runner_group
ocr_file = runner_group.files.find { |file| file.path == "CartOCR.swift" }
ocr_file ||= runner_group.new_file("CartOCR.swift")
unless runner.source_build_phase.files_references.include?(ocr_file)
  runner.add_file_references([ocr_file])
end
notification_file = runner_group.files.find { |file| file.path == "LocalNotificationBridge.swift" }
notification_file ||= runner_group.new_file("LocalNotificationBridge.swift")
unless runner.source_build_phase.files_references.include?(notification_file)
  runner.add_file_references([notification_file])
end

runner.build_configurations.each do |configuration|
  configuration.build_settings["CODE_SIGN_ENTITLEMENTS"] = "Runner/Runner.entitlements"
end

extension = project.targets.find { |target| target.name == "ShareExtension" }
unless extension
  group = project.main_group.find_subpath("ShareExtension", true)
  group.set_source_tree("<group>")
  swift = group.new_file("ShareExtension/ShareViewController.swift")
  group.new_file("ShareExtension/Info.plist")
  group.new_file("ShareExtension/ShareExtension.entitlements")

  extension = project.new_target(
    :app_extension,
    "ShareExtension",
    :ios,
    "13.0"
  )
  extension.add_file_references([swift])
  runner.add_dependency(extension)
  embed_phase = runner.new_copy_files_build_phase("Embed Foundation Extensions")
  embed_phase.dst_subfolder_spec = "13"
  embed_phase.add_file_reference(extension.product_reference)
end

embed_phase = runner.copy_files_build_phases.find do |phase|
  ["Embed App Extensions", "Embed Foundation Extensions"].include?(phase.name)
end
if embed_phase
  embed_phase.name = "Embed Foundation Extensions"
  runner.build_phases.delete(embed_phase)
  runner.build_phases.insert(0, embed_phase)
end

extension.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings["CODE_SIGN_ENTITLEMENTS"] = "ShareExtension/ShareExtension.entitlements"
  settings["CURRENT_PROJECT_VERSION"] = build_number
  settings["GENERATE_INFOPLIST_FILE"] = "NO"
  settings["INFOPLIST_FILE"] = "ShareExtension/Info.plist"
  settings["MARKETING_VERSION"] = marketing_version
  settings["PRODUCT_BUNDLE_IDENTIFIER"] =
    "com.shoppingguardian.shoppingGuardian.ShareExtension"
  settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  settings["SKIP_INSTALL"] = "YES"
  settings["SWIFT_VERSION"] = "5.0"
  settings["TARGETED_DEVICE_FAMILY"] = "1,2"
end
unless extension.source_build_phase.files_references.include?(shared_file)
  extension.add_file_references([shared_file])
end
unless extension.resources_build_phase.files_references.include?(privacy_file)
  extension.resources_build_phase.add_file_reference(privacy_file)
end

# Swift links Foundation automatically. xcodeproj otherwise adds an SDK-versioned
# file reference that becomes stale when Xcode updates its bundled SDK.
extension.frameworks_build_phase.files.each do |build_file|
  if build_file.file_ref&.path&.end_with?("Foundation.framework")
    build_file.remove_from_project
  end
end
project.files
  .select { |file| file.path&.end_with?("Foundation.framework") }
  .each(&:remove_from_project)
2.times do
  project.groups
    .select { |group| group.children.empty? && ["Frameworks", "iOS"].include?(group.name) }
    .each(&:remove_from_project)
end

project.save
