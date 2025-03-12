#Contents
This repository holds several scripts I plan on using to set up SSH and FTP services during NCAE 2025.

##setup_ftp_scoring.sh
This should be ran first. This file installs FTP on the system and quickly is able to check for errors, hopefully correctly!

##create_ftp_users.sh
This file sets up FTP users as they are listed as of writing. Assuming that they don't change usernames or password hash, it will be a great way to set up all users in one fell swoop.

##create_ftp_users_io.sh
This is a backup for above if they change password hash and/or user list. It takes in user input instead of having a set list of users and can be used simply: just type names until you're done, when you are done simply type "done".
