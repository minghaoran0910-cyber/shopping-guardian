# ML Kit discovers these registrars from AndroidManifest metadata through
# Firebase ComponentDiscovery. R8 can preserve their class names while removing
# the no-argument constructors that reflection needs, which breaks OCR only in
# release builds.
-keep class * implements com.google.firebase.components.ComponentRegistrar {
    public <init>();
}
