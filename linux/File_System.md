# File Type In Linux

In Linux, each file has a file type, which is represented by an identifier in the file system. Here are some common Linux file types:

- Regular file: A file that contains text, data, or program code. It can be further classified into text files and binary files.

- Directory: A folder that contains other files and directories. Directories themselves are files that contain pointers to other files and directories.

- Symbolic link: Also known as a soft link, it is a file that points to another file or directory. Symbolic links can cross different file systems and can be used to create links to directories.

- Socket: A file type used for inter-process communication. It can be a local socket (Unix socket) or a network socket (IP socket).

- Block device: A file type used to interact with device drivers, such as hard disks and USB drives.

- Character device: A file type used to interact with device drivers, such as keyboards and mice.

- FIFO: A file type used for inter-process communication. It is a special type of file that can be used to transfer data between multiple processes.

# Check File Type By `ls`

When viewing files using the ls command, the file type is represented by the first one or two letters in the file name. The common file types and their corresponding letters are as follows:

- Regular file: - (hyphen)
- Directory: d
- Symbolic link: l
- Socket: s
- Block device: b
- Character device: c
- FIFO: p

For example, if a file named example.txt is a regular file, the ls command displays it as `-rw-r--r--` example.txt in the list. If a file named mydir is a directory, the `ls` command displays it as `drwxr-xr-x` mydir. If a file named mylink is a symbolic link, the ls command displays it as `lrwxrwxrwx` mylink -> target.

