# Sideloading iOS Apps

With a paid Apple Developer account, you can sideload apps onto an iOS device for up to 1 year by signing them locally. This means you don't need to use services like AltStore or [SideStore][2] to sideload applications.

## Configuration

1. Open `Xcode.app`, navigate to `Settings` → `Account`, and double click either the team or your personal user to display a modal containing your signing certificates. Ensure a signing certificate exists for your user. If one does not exist, you can create one in the bottom-left corner by clicking the "Plus" dropdown and then "Apple Development".

   * Note there will be a "Personal Team" listed under the `Account` section. Don't use this one. From [Apple's documentation][3]:

        > A: Xcode 7 and Xcode 8 allow you to select the free personal team provided with your Apple ID for signing your app. This team allows you to build apps for your personal use on devices owned by you, but it does not allow you to code sign apps destined for the App Store or for enterprise use.
        > 
        > You can identify this account by looking in the accounts tab of the Xcode preferences. It is also displayed in the team menu displayed in a target's general build settings. Your personal account will be the account with the string '(Personal Team)' beside the name.

        Additional info TK TK TK https://itecnote.com/tecnote/xcode-how-to-manage-personal-team-info-on-apple-developer-website/

    * Once created, visit `Keychain Access.app` and you will see two new entries:
        1. A private key titled `Apple Development: <Name> (<Team Name>)`
        2. A certificate title `Apple Development: <Name> (<Team ID>)`
   
    * You can also visit "[Certificates, Identifiers & Profiles][5]" and see the certificate present there.
   
2. Create a Wildcard App Identifier in the [Identifiers section][6] of developer.apple.com. The "Description" will end up being the identifier of the identifier, set the "Bundle ID" to "Wildcard" with an asterisk. No capabilities or app servces seem to be needed.

3. Ensure the device you'd like to load the application on is present in the [Devices section][7] of developer.apple.com. TK TK TK

    * Find your UDID by TK TK TK

4. Finally, relate all of these entities together using a "Profile", which is, as Apple describes it: 

    > Provisioning profiles allow you to install apps onto your devices. A provisioning profile includes signing certificates, device identifiers, and an App ID.

    Click "Generate Profile", and follow the provisioning profile registration flow:

    1. TK TK TK
   2. TK TK TK
   3. 

5. iOS AppSigner (brew) https://dantheman827.github.io/ios-app-signer
6. Xcode devices didn't work 
7. Install via Apple Configurator 2 instead
8. "The app cannot be installed because its integrity could not be verified!" https://www.reddit.com/r/iOSProgramming/comments/10sni2r/the_app_cannot_be_installed_because_its_integrity/

Interesting info: https://stackoverflow.com/questions/58649251/xcode-how-to-add-a-private-key-to-development-certificate-if-its-created-using/58847332#58847332

## Deleting Certificates

You will notice when right-clicking on an existing certificate that "Delete Certificate" is disabled (or at least I have never seen it available as an option). Deleting a certificate properly depends on which "team" you plan to delete a certificate for:

**For "Personal Teams"**, it is not recommended to "delete" certificates, and it may not be possible to properly delete them at all. If you must, you can open `Keychain Access.app`, and clear out the "App Development" certificate and private key records that match your personal team. Doing this though will result in the certificate _not being deleted_ from the certificates modal, but rather being greyed out with a status of "Not in Keychain".

**For an Organization**, head to [developer.apple.com][4], click through to "[Certificates, Identifiers & Profiles][5]", select the certificate, and click "Revoke" in the top-right corner.

[1]: https://github.com/altstoreio/AltStore
[2]: https://sidestore.io
[3]: https://developer.apple.com/library/archive/qa/qa1915/_index.html
[4]: https://developer.apple.com
[5]: https://developer.apple.com/account/resources/certificates/list
[6]: https://developer.apple.com/account/resources/identifiers/list
[7]: https://developer.apple.com/account/resources/devices/list