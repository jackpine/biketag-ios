Building for Testers
--------------------
Building a "Beta" release to distribute to testers requires installing

1. iOS Distribution Certificate
2. AdHoc Provisioning Profile

Recent copies of both are included in this repository. If you need
access to these files, send your public gpg key to Michael.

    cd secrets
    gpg --decrypt ios_distribution.cer.gpg > ios_distribution.cer
    gpg --decrypt BikeTag_AdHoc.mobileprovision.gpg > BikeTag_AdHoc.mobileprovision

Verify you've installed the distribution certificate by opening up you
Keychain Access app. You should see a valid entry for

    iPhone Distribution: Michael Kirk (CSBZ6R9U39)

If you need a more recent copy of the provisioning profile, or want to
edit it, you'll you need to log into the [the apple developer
portal](https://developer.apple.com). Ask Michael for the credentials.

Adding a Tester
---------------

