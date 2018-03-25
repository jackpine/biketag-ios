clean:
	rm -rf build
	rm -rf BikeTag.ipa
	rm -rf BikeTag.app.dSYM
	rm -rf BikeTag.app

# Builds an app for the iOS Simulators
app:
	./script/make-app.sh Debug

# Builds an ipa for physical devices
ipa:
	./script/make-ipa.sh Debug

xct:
	rm -rf build
	./script/make-xctest.sh

dependencies:
	carthage build --platform iOS

