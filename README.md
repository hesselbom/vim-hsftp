vim-hsftp
=========

SFTP for Vim: Sync local and remote files/folders inside vim.

Config
------
Create a config file called `.hsftp` in the root of your projects directory.

Example `.hsftp` config file - the amount of spaces do not matter:

    host   example.org
    user   username
    pass   Sup3rS3cureP4s$W0rd
    port   22
    remote /var/www/
    confirm_download 0
    confirm_upload 0


vim-hsftp searches up the current files (current buffers) directory path for a `.hsftp` config file, and assumes it is located at the projects root directory. This resembles how the SFTP plugin for Sublime Text 3 works.

e.g. if the local file in vim is located at `/example/dir/file.txt`, and the example config file shown above is located at `/example/.hsftp` - when you run `:Hupload`, vim-hsftp will upload the local file to the host `example.org` at the remote path `/var/www/dir/file.txt` via SFTP using the provided credentials.

### Usage
Run the command or use the mapping in vim on the current file/current buffer.

**Upload File** Upload the current file (current buffer) to the remote path.
    :Hupload
    <leader>hsu

**Download File** Download the current file (current buffer) from the remote path.
    :Hdownload
    <leader>hsd

**Upload Folder** Upload all files in the current folder (current buffer) to the remote path.
    :Hupdir
    <leader>hsf
