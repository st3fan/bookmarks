Bookmarks On The Go V2
======================

This is work in progress on Bookmarks On The Go v2. This is a complete rewrite from the version that was on the app store, which was based on the original Firefox Home source code.

Most of this code was written during my paternity leave in early 2014. I am making it available under the MPL now, because it is very difficult for me to finish this as a side-project.

Notes about the code
--------------------

There are three relatively independent parts:

 * FirefoxAccounts - Native client for FIrefox Accounts. This part of the code is probably the most stable. It contains a bunch of code that is not needed anymore since this was written some time ago and Firefox Accounts has moved forward fast. For example the KeyStretcher and all the SRP code can be thrown out. Maybe even everything now that FxA also has a good web based OAuth implementation.
 * Sync - Beginning of a sync engine. It syncs! But only one way. It is work in progress but capable of grabbing your stuff and keeping it up to date, correctly handling inserts, deletes and updates.
 * Utilities - Misc utility classes and functions to support the previous two

All the code has unit tests. But I broke many tests by commenting out usernames and passwords of test accounts. These need to be put back in.

The code is mostly about the backend side of things. I have not started any UI work yet.

