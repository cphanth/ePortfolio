#hashing and salting a password makes it harder for brute force attacks to succeed
#do not store password!

import hashlib
import os


users = {}  #create a dictionary of users to store salt and key

#add a username with their password (which will be salted and hashed)
username = 'Person1'
password = 'password123'

salt = os.urandom(32) #size returned in bytes

key = hashlib.pbkdf2_hmac(
    'sha256',   #hash digest algorithm for HMAC
    password.encode('utf-8'),   #convert password to bytes
    salt,   #provide a randomly generated salt
    100000  # number of iterations in calculation
)

#STORE the new user's username and salted/hashed password
users[username] =
{
    'salt' : salt,
    'key' : key
}
'''
# or store hash key and salt together to make a longer value; which takes longer for hackers to crack

storage = salt + key

#getting and parsing the values back by using the known salt and key lengths
salt_from_storage = storage[:32]    #32 is length of salt
key_from_storage = storage[32:]
'''


# here below, we can check a user's input against what we have stored in the dictionary

username_to_check = input("Enter username: ")
password_to_check = input("Enter password: ")

#this assumes the username is correct and held within the dictionary
#we extract the salt and key values stored within the dictionary
salt = users[username_to_check]['salt']
key = users[username_to_check]['key']

#now we salt and hash the new password input to check for matching
new_key = hashlib.pbkdf2_hmac(
    'sha256',
    password_to_check.encode('utf-8'),
    salt,
    100000
)

if new_key == key:
    #allow access because input value and stored values match
    print('Password is correct')
else:
    #access denied because input value and stored values don't match
    print('Password does not match')
