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
portal](https://developer.apple.com). Ask Michael for these credentials.

Adding a Tester
---------------

1. Invite them by email through Crashlytics Beta.
2. Once they accept the invitation, you can get their Device ID from the
   Crashlytics UI
3. Add their Device ID to the AdHoc Provisioning Profile at the [the
   apple developer portal](https://cradeveloper.apple.com). Ask Michael for
   these credentials.
4. Download (from the ADP) and double click on the freshly updated AdHoc
   Provisioning Profile.
5. Archive and upload the App to Crashlytics
6. Check the updated encrypted provisioning profile into the repository
   (secrets/BikeTag_AdHoc.mobileprovision.gpg).

    gpg --encrypt BikeTag_AdHoc.mobileprovision -r michael -r sam -r fern
    # DON'T CHECK IN THE UNENCRYPTED FILE!
    rm BikeTag_AdHoc.mobileprovision
    git add BikeTag_AdHoc.mobileprovision.gpg
    git commit -m 'updated provisioning profile'

