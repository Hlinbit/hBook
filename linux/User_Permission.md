# User Management

Create an user in linux.
```
sudo useradd -m username
``` 

Set password for user.
```
sudo passwd username
```

Set the shell for user.
```
sudo usermod -s /path/to/shell username
```

Command switch to new user
```
su - username
```

# File Permission

## An example of File Permission

Commands to check file permissions.
```
ls -l <filename>
```

An example of a file.
```
-rw-r--r-- 1 user group 0 Jun 27 13:00 example.txt
```

`-rw-r--r--`: 
    
    The first character `-` indicates that the file is an ordinary file, and the following characters indicate the access permission of the file.

    `rw-` indicates that owner has read and write permissions, but not execute permissions; 

    `r--` indicates that group and others have read permissions, but no write and execute permissions.

`1`: Indicates the number of hard links to the file, that is, how many file names point to the file.

`user`: Indicates the owner of the file.

`group`: Indicates the group to which the file belongs.


# User Group

Create user group.
```
sudo groupadd groupname
```

Add an user into a user group.
```
sudo usermod -aG groupname username
```

Change the user group of an user.
```
sudo usermod -g groupname username
```

In order for the configuration to take effect, logging out and loging back in.


# Change File Access Permission for An User

Change access permission for a file/directory. The permission is set to `-rw-rw-rw-` or `drw-rw-rw-`.
```
chmod 666 filename
```

Change access permission for all files in directory.
```
chmod -R 666 filename
```

Grant execution permissions to the owner of a file.
```
chmod +x filename
```

Grant read and write permissions to the owner of a file.
```
chmod +rw filename
```

Revoke the file owner's read permission for the file.
```
chmod -rw filename
```

# Change The owner and User Group For a file

```
sudo chown <newowner> file.txt
sudo chown -R newowner directory
sudo chown newowner:newgroup file
sudo chown :newgroup file
```